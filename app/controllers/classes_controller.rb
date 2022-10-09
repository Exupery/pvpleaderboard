class ClassesController < ApplicationController
  include Utils
  protect_from_forgery with: :exception

  def select_class
    @title = "Class / Spec Selection"
    @description = "WoW PvP leaderboard talents, stats, and gear by class and spec"

    @heading = "Select a Class and Spec"

    render "results_by_class"
  end

  def results_by_class
    class_slug = slugify params[:class]
    clazz = Classes.list[class_slug]
    if clazz.nil?
      redirect_to "/pvp"
      return nil
    end

    spec_slug = slugify params[:spec]
    spec_slugs = Specs.slugs
    full_slug = "#{class_slug}_#{spec_slug}"
    if !spec_slugs.key?(full_slug)
      redirect_to "/pvp/#{class_slug}"
      return nil
    end
    spec = spec_slugs[full_slug]

    @class_and_spec = "#{spec[:name]} #{clazz[:name]}"
    @title = @class_and_spec
    @description = "World of Warcraft PvP leaderboard talents, covenants, soulbinds, and conduits for #{@class_and_spec}"
    @heading = @class_and_spec
    @image = "#{request.base_url}/images/classes/#{class_slug}.png"

    @class_id = clazz[:id]
    @spec_id = spec[:id]

    @talent_counts = get_talent_counts
    @pvp_talent_counts = get_pvp_talent_counts
    @covenant_counts = get_covenant_counts
    @soulbind_counts = get_soulbind_counts
    @conduit_counts = get_conduit_counts
    @stat_counts = get_stat_counts
    @gear = get_most_equipped_gear_by_spec(@class_id, @spec_id)
    @legendary_counts = get_legendary_counts

    @total = total_player_count(@class_id, @spec_id)
  end

  private

  def get_talent_counts
    cache_key = "talent_counts_#{@class_id}_#{@spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT talents.id AS talent, COUNT(*) AS count FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_talents ON players.id=players_talents.player_id JOIN talents ON players_talents.talent_id=talents.id WHERE players.class_id=#{@class_id} AND players.spec_id=#{@spec_id} GROUP BY talent")
    rows.each do |row|
      h[row["talent"]] = row["count"].to_i
    end

    ## Resolving the updater bug that results in no talents
    ## for a spec has proven quite difficult - so until that
    ## is fixed at least make sure we're not caching the bogus
    ## data. (Or maybe the caching IS the issue?)
    nonzero = false
    h.each do |t, cnt|
      if cnt > 0 then
        nonzero = true
        break
      end
    end
    if nonzero
      Rails.cache.write(cache_key, h)
    else
      logger.warn("No talent counts found for #{@class_id}_#{@spec_id}")
    end

    return h
  end

  def get_pvp_talent_counts
    cache_key = "pvp_talent_counts_#{@spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT pvp_talents.id AS pvp_talent, COUNT(*) AS count FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_pvp_talents ON players.id=players_pvp_talents.player_id JOIN pvp_talents ON players_pvp_talents.pvp_talent_id=pvp_talents.id WHERE pvp_talents.spec_id=#{@spec_id} GROUP BY pvp_talent ORDER BY count DESC")
    rows.each do |row|
      h[row["pvp_talent"]] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def get_covenant_counts
    cache_key = "covenant_counts_#{@spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT covenants.name AS covenant_name, covenants.icon AS covenant_icon, COUNT(*) AS count FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_covenants ON players.id=players_covenants.player_id JOIN covenants ON players_covenants.covenant_id=covenants.id WHERE players.spec_id=#{@spec_id} GROUP BY covenants.name, covenants.icon ORDER BY count DESC")
    rows.each do |row|
      covenant = Covenant.new(row["covenant_name"], row["covenant_icon"])
      h[covenant] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def get_soulbind_counts
    cache_key = "soulbind_counts_#{@spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT soulbinds.name AS soulbind, COUNT(*) AS count FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_soulbinds ON players.id=players_soulbinds.player_id JOIN soulbinds ON players_soulbinds.soulbind_id=soulbinds.id WHERE players.spec_id=#{@spec_id} GROUP BY soulbind ORDER BY count DESC")
    rows.each do |row|
      h[row["soulbind"]] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def get_conduit_counts
    cache_key = "conduit_counts_#{@spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT conduits.name AS conduit, conduits.spell_id AS spell_id, COUNT(*) AS count FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_conduits ON players.id=players_conduits.player_id JOIN conduits ON players_conduits.conduit_id=conduits.id WHERE players.spec_id=#{@spec_id} GROUP BY conduit, spell_id ORDER BY count DESC")
    rows.each do |row|
      conduit = Conduit.new(row["conduit"], row["spell_id"])
      h[conduit] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def get_legendary_counts
    cache_key = "legendary_counts_#{@spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT players_legendaries.spell_id AS id, players_legendaries.legendary_name AS name, COUNT(*) AS count FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_legendaries ON players.id=players_legendaries.player_id WHERE players.spec_id=#{@spec_id} GROUP BY spell_id, legendary_name ORDER BY count DESC")
    rows.each do |row|
      legendary = Legendary.new(row["id"], row["name"])
      h[legendary] = row["count"].to_i
    end

    Rails.cache.write(cache_key, h)
    return h
  end

  def get_stat_counts
    cache_key = "stat_counts_#{@class_id}_#{@spec_id}"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)
    h = Hash.new
    cols = get_stat_cols
    return h if cols.empty?
      rows = ActiveRecord::Base.connection.execute("SELECT #{cols} FROM leaderboards JOIN players ON leaderboards.player_id=players.id JOIN players_stats ON players.id=players_stats.player_id WHERE players.class_id=#{@class_id} AND players.spec_id=#{@spec_id}")
    rows.each do |row|
      h.merge!(parse_stats_row row)
    end

    remove_unused_stats h

    Rails.cache.write(cache_key, h)
    return h
  end

end
