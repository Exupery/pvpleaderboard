module OverviewHelper
	def percent_counts hash
		h = Hash.new
		total = 0
		hash.each do |k, v|
			total += v
		end
		hash.each do |k, v|
			h[k] = (v.to_f / total * 100).round(1)
		end
		return h
	end

	def slugify txt
		return txt.downcase.sub(/\s/, "_")
	end
end
