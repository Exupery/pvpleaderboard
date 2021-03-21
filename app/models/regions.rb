include Utils

class Regions
	@@regions = ["EU", "US"]
  @@regions_with_all = @@regions + ["All"]
  @@regions_with_asia = @@regions + ["KR", "TW"]

	def self.list
	  return @@regions
	end

  def self.with_all
	  return @@regions_with_all
	end

  def self.with_asia
	  return @@regions_with_asia
  end
end