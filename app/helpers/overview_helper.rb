module OverviewHelper
	def faction_percent
		h = Hash.new
		total = 0
		@counts.each do |f, c|
			total += c
		end
		@counts.each do |f, c|
			h[f] = (c.to_f / total * 100).round(1)
		end
		return h
	end
end
