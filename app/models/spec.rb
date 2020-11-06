include Utils

class Spec
  attr_reader :id, :class_name, :name, :role, :icon, :slug

  def initialize(id, class_name, name, role, icon)
    @id = id
    @class_name = class_name
    @name = name
    @role = role
    @icon = icon
    @slug = slugify name
  end
end