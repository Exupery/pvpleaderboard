module OverviewHelper
	include Utils

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

	def spec_percent_counts
		h = Hash.new
		@specs.each do |slug, info|
			h[slug] = info.count
		end

		return percent_counts h
	end
end
