require 'sinatra'
require 'curb'
require 'json'

enable :logging
use Rack::CommonLogger

def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

def flash_xml
  content_type 'text/xml'
	@config = @config["testAds"][0] if @config["testAds"]
	@config = { "slotType" => "preroll",
		"slotTimePos" => 0,
		"duration" => 10,
		"contentType" => "video/mp4",
		"creativeApi" => "None",
		"baseUnit" => "video",
		"wrapperType" => nil}.merge(@config)
	erb :flash_xml, :format => :xml
end

get_or_post '/json/*' do 
  url = params[:splat][0]
  url += "?dl=1" if url =~ /dropbox.com/
  url.sub!(/http(s)?:\//, '\0/')
  logger.info url
	http = Curl.get(url) do |curl|
    curl.follow_location = true
  end
	@config = JSON.parse(http.body_str)
  flash_xml
end

get_or_post '/pastie/:id' do 
	http = Curl.get("http://pastie.org/pastes/#{params[:id]}/download")
	@config = JSON.parse(http.body_str)
  flash_xml
end
