module OverviewHelper
	def faction_percent
		h = Hash.new
		total = 0
		@factions.each do |f, c|
			total += c
		end
		@factions.each do |f, c|
			h[f] = (c.to_f / total * 100).round(1)
		end
		return h
	end

	def race_percent
		h = Hash.new
		total = 0
		@races.each do |r, c|
			total += c
		end
		@races.each do |r, c|
			h[r] = (c.to_f / total * 100).round(1)
		end
		return h
	end

	def slugify txt
		return txt.downcase.sub(/\s/, "_")
	end
end
