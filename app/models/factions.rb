include Utils

class Factions
	@@factions = nil

	def self.list
		@@factions = get_factions if @@factions.nil?
	  return @@factions
	end

	private

	def self.get_factions
		h = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT id, name FROM factions")
    rows.each do |row|
      n = row["name"]
      h[slugify n] = {:id => row["id"], :name => n}
    end

    return h
	end
end