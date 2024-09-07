include Utils

class Brackets
	@@brackets = ["2v2", "3v3", "rbg"]
  @@brackets_with_solo_blitz = ["solo", "blitz"].concat(@@brackets)

	def self.list
	  return @@brackets
	end

  def self.with_solo_blitz
	  return @@brackets_with_solo_blitz
	end
end