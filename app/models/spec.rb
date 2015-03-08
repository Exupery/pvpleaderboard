class Spec
  attr_reader :class_name, :name, :role, :description, :background_image, :icon, :slug

  def initialize(class_name, name, role, description, background_image, icon)
    @class_name = class_name
    @name = name
    @role = role
    @description = description
    @background_image = background_image
    @icon = icon
    @slug = name.downcase.sub(/-/, "_")
  end
end