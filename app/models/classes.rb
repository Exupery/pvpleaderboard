class Classes
	@@classes = nil

	def self.list
		@@classes = get_classes if @@classes.nil?
	  return @@classes
	end

	private

	def self.get_classes
		h = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT name FROM classes ORDER BY name ASC")
    rows.each do |row|
      n = row["name"]
      h[n] = n.downcase.sub(/\s/, "_")
    end

    return h
	end
end