include Utils

class Races
  @@races = nil
  @@names = nil

  def self.list
    @@races = get_races if @@races.nil?
    return @@races
  end

  def self.names
    @@names = get_names if @@names.nil?
    return @@names
  end

  private

  def self.get_races
    h = Hash.new

    rows = ActiveRecord::Base.connection.execute("SELECT id, name FROM races ORDER BY name ASC")
    rows.each do |row|
      slug = slugify row["name"]
      h[slug] = {:id => row["id"], :name => row["name"]}
    end

    return h
  end

  def self.get_names
    a = Array.new

    rows = ActiveRecord::Base.connection.execute("SELECT distinct name FROM races ORDER BY name ASC")
    rows.each do |row|
      a.push(row["name"])
    end

    return a
  end
end