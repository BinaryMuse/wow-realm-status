require 'sinatra'
require 'dalli'
require 'net/http'
require 'uri'
require 'json'
require 'partials'
require 'text_helpers'

helpers Sinatra::Partials
helpers Realmstatus::Helpers

set :cache, Dalli::Client.new(ENV['MEMCACHE_SERVERS'], 
    :username => ENV['MEMCACHE_USERNAME'], 
    :password => ENV['MEMCACHE_PASSWORD'], 
    :expires_in => 300) # Expire API data in 5 minutes

# No favicon
get '/favicon.ico' do
  nil
end

def set_cache(key, data)
  begin
    settings.cache.set(key, data)
  rescue Dalli::RingError
    nil
  end
end

def get_cache(key)
  begin
    settings.cache.get(key)
  rescue Dalli::RingError
    nil
  end
end

def realm_data
  json = ''
  begin
    json = get_cache('realm_json') || get_realm_json
  rescue Dalli::RingError
    json = get_realm_json
  end
  JSON::parse(json).fetch('realms')
end

def get_realm_json
  api_url = 'http://us.battle.net/api/wow/realm/status'
  uri     = URI.parse api_url
  json    = Net::HTTP.get(uri)
  set_cache('realm_json', json)
  set_cache('updated', Time.now)
  json
end

get '/' do
  @data = realm_data
  @time = get_cache('updated')
  haml :realms
end

get '/:realm' do |name|
  @data   = realm_data
  @search = name
  @time   = get_cache('updated')
  haml :realms
end
