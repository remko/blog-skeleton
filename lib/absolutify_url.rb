def absolutify_url(url, params = {})
	base = params[:base] || ""
	if /^(https?|mailto):/.match(url)
		url
	elsif url.start_with?("/")
		"#{base}#{url}"
	else
		"#{base}#{Pathname(params[:path]).parent + url}"
	end
end
