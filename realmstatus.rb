require 'sinatra'
require 'dalli'
require 'net/http'
require 'uri'
require 'json'
require 'partials'

helpers Sinatra::Partials
helpers do
  def proper_realm_type(type)
    case type
    when "pvp"
      "PvP"
    when "pve"
      "PvE"
    when "rp"
      "RP"
    when "rppvp"
      "RP PvP"
    end
  end
end

set :cache, Dalli::Client.new(ENV['MEMCACHE_SERVERS'], 
    :username => ENV['MEMCACHE_USERNAME'], 
    :password => ENV['MEMCACHE_PASSWORD'], 
    :expires_in => 300) # Expire API data in 5 minutes

# No favicon
get '/favicon.ico' do
  nil
end

def realm_data
  begin
    settings.cache.get('realm_json') || get_realm_json
  rescue Dalli::RingError
    get_realm_json
  end
end

def get_realm_json
  begin
    api_url = 'http://us.battle.net/api/wow/realm/status'
    uri     = URI.parse api_url
    json    = Net::HTTP.get(uri).to_s
    JSON::parse(json).fetch('realms')
  rescue
    haml :'500'
  end
end

get '/' do
  @data = realm_data
  haml :realms
end

get '/:realm' do
  data   = realm_data
  @realm = realm_data
end
