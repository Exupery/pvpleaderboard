module TalentsHelper
  include Utils

  def class_talent_counts_tree(class_id, spec_id, class_talent_counts)
    class_talents = Talents.get_class_talents(class_id, spec_id)
    talents_with_percents = get_percents(class_talents, class_talent_counts)
    return convert_to_tree(talents_with_percents)
  end

  def spec_talent_counts_tree(spec_id, spec_talent_counts)
    spec_talents = Talents.get_spec_talents(spec_id)
    talents_with_percents = get_percents(spec_talents, spec_talent_counts)
    return convert_to_tree(talents_with_percents)
  end

  def pvp_talent_counts(spec_id, pvp_talent_counts)
    pvp_talents = Pvptalents.get_talents(spec_id)
    return get_percents(pvp_talents, pvp_talent_counts)
  end

  def find_min_row talents
    return find_min(talents, "row")
  end

  def find_max_row talents
    return find_max(talents, "row")
  end

  def find_min_col talents
    return find_min(talents, "col")
  end

  def find_max_col talents
    return find_max(talents, "col")
  end

  private

  def find_min(talents, key)
    min = 2 ** 32

    talents.each do |id, talent|
      val = talent[:"#{key}"]
      min = val if val < min
    end

    return min
  end

  def find_max(talents, key)
    max = 0

    talents.each do |id, talent|
      val = talent[:"#{key}"]
      max = val if val > max
    end

    return max
  end

  def convert_to_tree(talents)
    tree = Hash.new

    talents.each do |id, talent|
      row = talent[:row]
      col = talent[:col]
      key = "#{row}-#{col}"
      if tree.include? key
        existing = tree[key]
        t = (existing[:percent] > talent[:percent]) ? existing : talent
        tree[key] = t
      else
        tree[key] = talent
      end
    end

    return tree
  end

  def get_percents(talents, talent_counts)
    h = Hash.new

    talent_counts.each do |id, count|
      talent = talents[id]
      next if talent.nil?
      talent[:percent] = (count.to_f / @total * 100).round(1)
      h[id] = talent
    end

    fill_missing(h, talents)

    return h
  end

  def fill_missing(pct_talents, all_talents)
    seen = Set.new # Seems Blizz has a bug where some talents are duped
    all_talents.each do |id, talent|
      next if (pct_talents.key?(id) || seen.include?(talent[:spell_id]))
      talent[:percent] = 0
      pct_talents[id] = talent
      seen.add(talent[:spell_id])
    end
  end

end
