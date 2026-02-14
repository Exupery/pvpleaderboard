include Utils

class Realm
  attr_reader :slug, :name, :region

  def initialize(slug, name, region)
    @slug = slug
    @name = name
    @region = region
  end
end

class Realms
	@@realms = nil

  def self.list
	  @@realms = get_realms if @@realms.nil?
	  return @@realms
	end

	private

	def self.get_realms
		h = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT slug, name, region FROM realms ORDER BY name ASC")
    rows.each do |row|
      slug = row["slug"]
      region = row["region"]
      h[slug + region] = Realm.new(slug, row["name"], region)
    end

    return h
	end
end