module NetHelper

  # Send a GET request to URL and follow through redirections
  def self.get_with_redirect(url_str, opts = {})
    limit = opts[:limit] || 10

    if limit.class != Integer || limit <= 0
      raise ArgumentError.new('Redirects limit must be an integer greater than 0.')
    end

    response = Net::HTTP.get_response(URI(url_str))

    case response
    when Net::HTTPSuccess then
      response
    when Net::HTTPRedirection then
      location = response['location']
      warn "Redirected to #{location}"
      get_with_redirect(location, :limit => limit - 1)
    else
      response.value
    end
  end

  # Download by streaming to given file
  def self.download_file(url_str, file_path)
    url = URI(url_str)

    Net::HTTP.start(url.host, url.port) do |http|
      request = Net::HTTP::Get.new(url)
    
      http.request(request) do |response|
        open(file_path, 'wb') do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
  end

end