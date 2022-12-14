include Utils

class Specs
	@@specs = nil
	@@slugs = nil
  @@solo_slugs = nil

	def self.list
		@@specs = get_specs if @@specs.nil?
	  return @@specs
	end

	def self.slugs
		@@slugs = get_slugs if @@slugs.nil?
	  return @@slugs
	end

  def self.solo_slugs
		@@solo_slugs = get_solo_slugs if @@solo_slugs.nil?
	  return @@solo_slugs
	end

	private

	def self.get_specs
		h = Hash.new

		rows = ActiveRecord::Base.connection.execute("SELECT specs.id AS id, classes.name AS class, specs.name AS spec, role, icon FROM specs JOIN classes ON specs.class_id=classes.id ORDER BY spec ASC")
    rows.each do |row|
    	clazz = row["class"]
      spec = Spec.new(row["id"], clazz, row["spec"], row["role"], row["icon"])
      h[clazz] = Array.new if !h.key?(clazz)
      h[clazz] = h[clazz].insert(-1, spec)
    end

    return h
	end

	def self.get_slugs
		h = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT specs.id AS id, classes.name AS class, specs.name AS spec FROM specs JOIN classes ON specs.class_id=classes.id ORDER BY class, spec ASC")
    rows.each do |row|
      clazz = row["class"]
      spec = row["spec"]
      slug = slugify "#{clazz}_#{spec}"
      h[slug] = {:id => row["id"], :name => spec}
    end

    return h
	end

  def self.get_solo_slugs
		h = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT specs.id AS id, classes.name AS class, specs.name AS spec FROM specs JOIN classes ON specs.class_id=classes.id")
    rows.each do |row|
      clazz = solo_slugify row["class"]
      spec = solo_slugify row["spec"]
      slug = "shuffle-#{clazz}-#{spec}"
      h[row["id"]] = slug
    end

    return h
	end

  def self.solo_slugify name
    return name.downcase.gsub(/\s/, "")
  end
end