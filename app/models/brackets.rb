include Utils

class Brackets
	@@brackets = ["2v2", "3v3", "rbg"]
  @@brackets_with_solo = ["solo"].concat(@@brackets)

	def self.list
	  return @@brackets
	end

  def self.with_solo
	  return @@brackets_with_solo
	end
end