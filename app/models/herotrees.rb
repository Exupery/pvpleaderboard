require "concurrent"
require "httparty"
require "set"
require "yajl/json_gem"

# Hero talent trees (Master of Harmony, Shado-Pan, ...).
#
# Blizzard doesn't hand out tree names with the talents themselves so they
# aren't in our DB, but the set of specs that share a hero tree is - that's
# the hero_specs array on every cat='HERO' talent, and it identifies the
# tree uniquely within a class. Names get stitched on by asking the API
# which hero trees each spec can use and inverting that into spec set =>
# name. If the API can't be reached we fall back to naming a tree after its
# first talent, which is usually close enough to the tree's real name.
class Herotrees
  @@trees = nil
  @@from_api = false
  @@loaded_at = nil

  @@CACHE_KEY = "hero_trees"
  @@CACHE_TTL = 7.days
  # Don't keep hammering the API when it's down, but don't stay stuck on
  # fallback names for the life of the process either
  @@FALLBACK_RETRY_AFTER = 5.minutes

  @@TREE_INDEX_URI = "https://us.api.blizzard.com/data/wow/talent-tree/index?namespace=static-us&locale=en_US"
  @@SPEC_URI = "https://us.api.blizzard.com/data/wow/playable-specialization/%d?namespace=static-us&locale=en_US"
  @@OAUTH_URI = "https://us.battle.net/oauth/token"
  @@OAUTH_CACHE_KEY = "oauth_access_token"
  @@BEARER_HEADER = "Bearer %s"
  @@TIMEOUT = 5

  # All known hero trees keyed by the underscore joined spec set Talents
  # uses for hero_specs, eg "268_270" => {:name => "Master of Harmony", ...}
  def self.list
    @@trees = load_trees if reload?
    return @@trees
  end

  # The hero trees a spec can pick from, sorted by name
  def self.for_spec spec_id
    return [] unless spec_id.is_a? Numeric

    return list.values.select { |tree| tree[:specs].include? spec_id }.sort_by { |tree| tree[:name] }
  end

  # Looks a spec's hero tree up by slug, nil unless the slug names one of
  # the trees that spec can actually pick - callers rely on this to reject
  # anything that came in off a query string
  def self.find(spec_id, slug)
    return nil if slug.nil?

    return for_spec(spec_id).find { |tree| tree[:slug] == slug }
  end

  # Name of the tree a group of hero talents belongs to, keyed the way
  # Talents reports hero_specs
  def self.name_for key
    tree = list[key]
    return tree.nil? ? nil : tree[:name]
  end

  # Drops the memoized trees, letting the next call rebuild them
  def self.reset!
    @@trees = nil
    @@from_api = false
    @@loaded_at = nil
  end

  private

  def self.reload?
    return true if @@trees.nil?
    return false if @@from_api

    return @@loaded_at.nil? || @@loaded_at < @@FALLBACK_RETRY_AFTER.ago
  end

  def self.load_trees
    cached = Rails.cache.read(@@CACHE_KEY)
    unless cached.nil?
      memoize(cached, true)
      return cached
    end

    trees = trees_from_api
    if trees.empty?
      Rails.logger.warn("Naming hero trees from the API failed, falling back to first talent names") if api_enabled?
      memoize(fallback_trees, false)
      return @@trees
    end

    Rails.cache.write(@@CACHE_KEY, trees, :expires_in => @@CACHE_TTL)
    memoize(trees, true)
    return trees
  end

  def self.memoize(trees, from_api)
    @@trees = trees
    @@from_api = from_api
    @@loaded_at = Time.now
  end

  # Builds spec set => tree by asking every spec which hero trees it can
  # use and inverting the result. Blizzard mixes unreleased placeholder
  # trees into those lists (the Druid "[DNT]" ones) and their spec sets
  # collide with real trees, so the tree index - which lists only the real
  # ones - decides what counts.
  # Tests name trees from the DB so the suite stays off the network
  def self.api_enabled?
    return Rails.configuration.x.hero_trees_from_api != false
  end

  def self.trees_from_api
    trees = Hash.new
    return trees unless api_enabled?

    # Grab the token up front so the threads below share one instead of
    # each racing to create its own
    headers = create_headers
    return trees if headers.nil?

    real_ids = real_tree_ids headers
    return trees if real_ids.empty?

    by_id = Concurrent::Hash.new
    threads = Specs.specs_by_id.keys.map do |spec_id|
      Thread.new { by_id[spec_id] = hero_trees_for_spec(spec_id, headers) }
    end
    threads.each { |t| t.join }

    collected = Hash.new
    by_id.each do |spec_id, spec_trees|
      spec_trees.each do |tree|
        next unless real_ids.include? tree[:id]
        collected[tree[:id]] ||= {:id => tree[:id], :name => tree[:name], :class_id => tree[:class_id], :specs => []}
        collected[tree[:id]][:specs].push spec_id
      end
    end

    collected.each_value do |tree|
      specs = tree[:specs].sort
      trees[key_for specs] = {
        :id => tree[:id],
        :name => tree[:name],
        :slug => slug_for(tree[:name]),
        :class_id => tree[:class_id],
        :specs => specs
      }
    end

    return trees
  end

  def self.real_tree_ids headers
    index = get(@@TREE_INDEX_URI, headers)
    hero_trees = index["hero_talent_trees"]
    return Set.new if hero_trees.nil?

    return Set.new(hero_trees.map { |tree| tree["id"] }.compact)
  end

  def self.hero_trees_for_spec(spec_id, headers)
    spec = get(@@SPEC_URI % [spec_id], headers)
    hero_trees = spec["hero_talent_trees"]
    return [] if hero_trees.nil?

    class_id = spec.dig("playable_class", "id")
    return hero_trees.map { |tree|
      {:id => tree["id"], :name => tree["name"], :class_id => class_id}
    }.select { |tree| !tree[:id].nil? && !tree[:name].nil? }
  end

  # Names each tree after its first talent - not the tree's real name, but
  # the first talent usually defines the tree so it still reads sensibly
  def self.fallback_trees
    trees = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT DISTINCT ON (class_id, hero_specs) class_id, hero_specs, name FROM talents WHERE cat='HERO' ORDER BY class_id, hero_specs, display_row ASC, display_col ASC, id ASC")
    rows.each do |row|
      specs = parse_specs row["hero_specs"]
      next if specs.empty?
      trees[key_for specs] = {
        :id => nil,
        :name => row["name"],
        :slug => slug_for(row["name"]),
        :class_id => row["class_id"],
        :specs => specs
      }
    end

    return trees
  end

  def self.key_for specs
    return specs.join("_")
  end

  # Same as Utils#urlify but also drops the punctuation urlify leaves
  # alone, which the API's tree names don't have but the talent names the
  # fallback borrows do ("Invoke Xuen, the White Tiger"). Spelled out here
  # rather than pulled in from Utils so this class doesn't have to include
  # a reloadable module into Object the way the other models do - it gets
  # autoloaded from inside a view render, and mutating Object's method
  # table mid-render is not something to do on a threaded server.
  def self.slug_for name
    return name.to_s.downcase.gsub(/[_\s]/, "-").gsub(/[^a-z0-9\-]/, "").gsub(/\-+/, "-").gsub(/\A\-|\-\z/, "")
  end

  def self.parse_specs specs_array
    return [] if specs_array.nil?

    return specs_array.to_s.gsub(/[{}\s]/, "").split(",").map { |id| id.to_i }.sort
  end

  def self.get(uri, headers)
    res = HTTParty.get(uri, timeout: @@TIMEOUT, headers: headers)
    return Hash.new if (res.body.nil? || res.code != 200)

    return JSON.parse(res.body)
  rescue StandardError => e
    Rails.logger.warn("Could not GET #{uri} - #{e.message}")
    return Hash.new
  end

  def self.create_headers
    token = create_token
    return nil if token.nil?

    return {"Authorization" => @@BEARER_HEADER % [token]}
  rescue StandardError => e
    Rails.logger.warn("Creating OAUTH token failed - #{e.message}")
    return nil
  end

  def self.create_token
    return Rails.cache.read(@@OAUTH_CACHE_KEY) if Rails.cache.exist?(@@OAUTH_CACHE_KEY)
    res = HTTParty.post(@@OAUTH_URI, timeout: @@TIMEOUT, body: {
      client_id: ENV["BATTLE_NET_CLIENT_ID"],
      client_secret: ENV["BATTLE_NET_SECRET"],
      grant_type: "client_credentials"
    })
    return nil if res.code != 200
    access_token = res.parsed_response["access_token"]
    return nil if access_token.nil?

    Rails.cache.write(@@OAUTH_CACHE_KEY, access_token, :expires_in => 30.minutes)
    return access_token
  end
end
