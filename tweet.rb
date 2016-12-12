require 'openssl'
require 'net/http'
require 'base64'
require 'cgi'

def escape(string)
	CGI.escape(string).gsub('+', '%20')
end

def oauth_string(url, method='GET', args={})
	oauth_consumer_key = ENV['TWITTER_OAUTH_CONSUMER_KEY']	
	if !oauth_consumer_key then
		raise 'TWITTER_OAUTH_CONSUMER_KEY not set'
	end
	oauth_consumer_secret = ENV['TWITTER_OAUTH_CONSUMER_SECRET']
	if !oauth_consumer_secret then
		raise 'TWITTER_OAUTH_CONSUMER_SECRET not set'
	end
	oauth_token = ENV['TWITTER_OAUTH_TOKEN']
	if !oauth_token then
		raise 'TWITTER_OAUTH_TOKEN not set'
	end
	oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
	if !oauth_token_secret then
		raise 'TWITTER_OAUTH_TOKEN_SECRET not set'
	end
	oauth_nonce=Random.rand(2**32)
	oauth_signature_method='HMAC-SHA1'
	oauth_timestamp = Time.now.to_i

	oauth_args = Hash.new

	oauth_args[:oauth_consumer_key] = oauth_consumer_key
	oauth_args[:oauth_token] = oauth_token
	oauth_args[:oauth_nonce] = oauth_nonce
	oauth_args[:oauth_signature_method] = oauth_signature_method
	oauth_args[:oauth_timestamp] = oauth_timestamp
	oauth_args[:oauth_version] = '1.0'

	all_args = oauth_args.merge(args)

	parameters_base_string = all_args.keys.sort.map{|key| "#{escape(key.to_s)}=#{escape(all_args[key].to_s)}"}.join('&')

	escaped_base_string = escape(parameters_base_string)

	signature_base_string = "#{method.upcase}&#{escape(url)}&#{escaped_base_string}"
	signing_key = "#{oauth_consumer_secret}&#{oauth_token_secret}"

	oauth_signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), signing_key, signature_base_string)).strip!

	oauth_args[:oauth_signature] = escape(oauth_signature)

	auth_string = "OAuth "
	auth_string += oauth_args.keys.sort.map{|k| "#{k}=\"#{oauth_args[k].to_s}\""}.join(',')
	
	return auth_string
end

if !ENV.has_key?('XCS') then
	raise 'script must be run from xcode instance'
end

status = "#{ENV['XCS_BOT_NAME']} #{ENV['XCS_INTEGRATION_NUMBER']}: #{ENV['XCS_INTEGRATION_RESULT']}"

url = 'https://api.twitter.com/1.1/statuses/update.json'
uri = URI(url)
req = Net::HTTP::Post.new(uri)
args = {:status => status}

req.body = args.map{|k, v| "#{escape(k.to_s)}=#{escape(v.to_s)}"}.join("\n")

req['Authorization'] = oauth_string(url, 'post', args)

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
puts req.body
res = http.request req
