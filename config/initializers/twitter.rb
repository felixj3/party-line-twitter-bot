# apparently there's no need for require 'twitter' line because the name of this file is the same name as the gem?

# unable to access client variable in other parts of code
# moved this code to model

CLIENT = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["CONSUMER_KEY"]
    config.consumer_secret     = ENV["CONSUMER_SECRET"]
    config.access_token        = ENV["ACCESS_TOKEN"]
    config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end