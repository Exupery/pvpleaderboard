include Utils

class Regions
	@@regions = ["EU", "US"]
  @@regions_with_all = @@regions + ["All"]

	def self.list
	  return @@regions
	end

  def self.with_all
	  return @@regions_with_all
	end
end