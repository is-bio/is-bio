class GithubClient
  API_BASE_URL = "https://api.github.com"

  def initialize
    @conn = Faraday.new do |builder|
      # builder.request :json
      builder.response :raise_error
      builder.response :json
    end
  end

  def compare(github_username, before, after)
    @conn.get("#{API_BASE_URL}/repos/#{github_username}/markdown-blog/compare/#{before}...#{after}") do |req|
      req.headers = request_headers
      req.options.timeout = 10
    end
  end

  def file_contents(url)
    @conn.get(url) do |req|
      req.headers = { Accept: "application/vnd.github.v3.raw" }
      req.options.timeout = 10
    end
  end

  protected

  def request_headers
    { Accept: "application/vnd.github+json" }
  end
end
