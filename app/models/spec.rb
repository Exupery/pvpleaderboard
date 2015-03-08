include Utils

class Spec
  attr_reader :id, :class_name, :name, :role, :description, :background_image, :icon, :slug

  def initialize(id, class_name, name, role, description, background_image, icon)
    @id = id
    @class_name = class_name
    @name = name
    @role = role
    @description = description
    @background_image = background_image
    @icon = icon
    @slug = slugify name
  end
end