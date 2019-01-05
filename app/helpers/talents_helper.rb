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
    normalize h
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

  # Adjust percentages if row doesn't isn't near 100.
  # This can occur if a large number of players of
  # a class/spec don't have talents selected (e.g. they
  # were reset by Blizzard following major class revamp)
  def normalize hash
    (0..6).each do |tier|
      talent = -> row { hash["#{tier}-#{row}"] }
      total = talent.(0)[:percent] + talent.(1)[:percent] + talent.(2)[:percent]
      next if total == 0 # don't normalize if NO talents selected (e.g. immediately after a talent refund)
      if (total < 95) then
        mod = 100 / total
        (0..2).each { |row|
          per = (talent.(row)[:percent] * mod).round(1)
          talent.(row)[:percent] = per > 0.1 ? per : 0
        }
      end
    end
  end

end
