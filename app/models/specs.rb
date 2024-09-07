include Utils

class Specs
	@@specs = nil
	@@slugs = nil
  @@solo_slugs = nil
  @@blitz_slugs = nil
  @@specs_by_id = nil

	def self.list
		@@specs = get_specs if @@specs.nil?
	  return @@specs
	end

	def self.slugs
		@@slugs = get_slugs if @@slugs.nil?
	  return @@slugs
	end

  def self.solo_slugs
		@@solo_slugs = get_prefixed_slugs("shuffle") if @@solo_slugs.nil?
	  return @@solo_slugs
	end

  def self.blitz_slugs
		@@blitz_slugs = get_prefixed_slugs("blitz") if @@blitz_slugs.nil?
	  return @@blitz_slugs
	end

  def self.specs_by_id
		@@specs_by_id = get_specs_by_id if @@specs_by_id.nil?
	  return @@specs_by_id
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

  def self.get_specs_by_id
		h = Hash.new

		rows = ActiveRecord::Base.connection.execute("SELECT specs.id AS id, classes.name AS class, specs.name AS spec FROM specs JOIN classes ON specs.class_id=classes.id ORDER BY id ASC")
    rows.each do |row|
      h[row["id"]] = {
        :class => row["class"],
        :spec => row["spec"]
      }
    end

    return h
	end

  def self.get_prefixed_slugs prefix
		h = Hash.new()

		rows = ActiveRecord::Base.connection.execute("SELECT specs.id AS id, classes.name AS class, specs.name AS spec FROM specs JOIN classes ON specs.class_id=classes.id")
    rows.each do |row|
      clazz = prefixed_slugify row["class"]
      spec = prefixed_slugify row["spec"]
      slug = "#{prefix}-#{clazz}-#{spec}"
      h[row["id"]] = slug
    end

    return h
	end

  def self.prefixed_slugify name
    return name.downcase.gsub(/\s/, "")
  end
end