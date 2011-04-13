require 'sinatra'
require 'dalli'
require 'net/http'
require 'uri'
require 'json'
require 'partials'

helpers Sinatra::Partials
helpers do
  def link_to(text, url)
    "<a href='#{url}' />#{text}</a>"
  end

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

  def proper_realm_pop(pop)
    case pop
    when "high"
      "High"
    when "medium"
      "Medium"
    when "low"
      "low"
    else
      pop
    end
  end

  def realm_matches(realm, text)
    realm["slug"].start_with?(text) || realm["name"].start_with?(text)
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

def set_cache(key, data)
  begin
    settings.cache.set(key, data)
  rescue Dalli::RingError
    nil
  end
end

def get_cache(key)
  begin
    settings.cache.get('realm_json')
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
  json
end

get '/' do
  @data = realm_data
  haml :realms
end

get '/:realm' do |name|
  # @data = realm_data.find_all do |realm|
  #   realm["slug"].start_with?(name) || realm["name"].start_with?(name)
  # end
  @data   = realm_data
  @search = name
  haml :realms
end

get '/wtf' do
  return haml :'500'
end
