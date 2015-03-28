include Utils

class Races
  @@races = nil

  def self.list
    @@races = get_races if @@races.nil?
    return @@races
  end

  private

  def self.get_races
    a = Array.new()

    rows = ActiveRecord::Base.connection.execute("SELECT distinct name FROM races ORDER BY name ASC")
    rows.each do |row|
      a.push(row["name"])
    end

    return a
  end
end