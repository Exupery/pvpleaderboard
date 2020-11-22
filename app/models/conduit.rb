class Conduit
  attr_reader :name, :spell_id

  def initialize(name, spell_id)
    @name = name
    @spell_id = spell_id
  end
end