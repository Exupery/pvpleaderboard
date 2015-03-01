module ApplicationHelper
	def is_active path
		return request.env["PATH_INFO"] == path ? "active" : "" if path == "/"
		return request.env["PATH_INFO"].start_with?(path) ? "active" : ""
	end
end
