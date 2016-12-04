module TalentsHelper
	include Utils

	def talent_counts_table(class_id, spec_id)
		h = Hash.new
		@class_talents = Talents.get_talents(class_id, spec_id)

		@talent_counts.each do |id, count|
			talent = @class_talents[id]
			next if talent.nil?
			talent[:percent] = (count.to_f / @total * 100).round(1)
			k = "#{talent[:tier]}-#{talent[:col]}"
			h[k] = talent
		end

		fill_missing h if h.size < 21
		assign_highest h
		return h
	end

	private

	def fill_missing hash
		@class_talents.each do |_id, talent|
			k = "#{talent[:tier]}-#{talent[:col]}"
			if !hash.has_key?(k)
				talent[:percent] = 0
				hash[k] = talent
			end
		end
	end

	def assign_highest hash
		(0..6).each do |t|
			highest = 0
			high_col = 0
			(0..2).each do |c|
				k = "#{t}-#{c}"
				p = hash[k][:percent]
				if p > highest
					highest = p
					high_col = c
				end
			end
			hash["#{t}-#{high_col}"][:highest] = true if highest > 0
		end
	end

end
