module ApplicationHelper
	def is_active path
		return request.env["PATH_INFO"] == path ? "active" : "" if path == "/"
		return request.env["PATH_INFO"].start_with?(path) ? "active" : ""
	end

  def is_active_bracket(bracket, region)
    return false if (@bracket.nil? || @region.nil?)

    bracket_match = bracket.casecmp(@bracket) == 0
    region_match = region.casecmp(@region) == 0

    return bracket_match && region_match
  end
end
