include Utils

class Realms
	@@realms = nil

	def self.list
	  return @@realms
	end

	private

	def self.get_realms
		h = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT slug, name FROM realms ORDER BY name ASC")
    rows.each do |row|
      h[row["slug"]] = row["name"]
    end

    @@realms = h
	end

  get_realms
end