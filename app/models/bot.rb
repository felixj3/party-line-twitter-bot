class Bot < ApplicationRecord
    def self.test
        # puts ENV['test']
        # puts TEST
    end

    def self.update
        CLIENT.update("Tweet with a gem")
    end

    def self.update(status)
        CLIENT.update(status)
    end

    # reply to tweet with status
    # screen_name should not include @ symbol, refers to the name of the user's tweet this method is replying to
    def self.reply(status, tweet, screen_name)
        CLIENT.update("@#{screen_name} #{status}", in_reply_to_status: tweet)
    end

    def self.get_user(screen_name)
        return CLIENT.user(screen_name)
        # issue when trying Bot.get_user when using @client instead of CLIENT
        # most likely that instance of BOT didn't have @client so the user returned was nil
    end

    # returns most recent tweet from user that isn't a reply and the full length text of tweet
    # returns the tweet and string in an array, with tweet being first and then text
    # if 100 most recent tweets are all replies, returns the most recent reply
    def self.get_tweet(screen_name)
        user = Bot.get_user(screen_name)
        tweet_array = CLIENT.user_timeline(user, count: 100)
        tweet_array.each do |tweet|
            puts tweet.full_text # isn't actual full_text
            actual_full_text = Bot.get_tweet_full_length(tweet)
            puts actual_full_text
            puts "---------------"
            if tweet.in_reply_to_user_id.is_a?(Twitter::NullObject) && !tweet.text.starts_with?("@") && !tweet.text.starts_with?("RT") && actual_full_text.length <= 280 && UsedTweet.find_by(tweet_id: tweet.id) == nil
                # checks if the tweet is not a reply, not a retweet, under 280 characters, and the bot hasn't tweeted before
                return tweet, actual_full_text
            end
        end
        return tweet_array[0], Bot.get_tweet_full_length(tweet_array[0])
    end

    # gets full length text of tweet
    def self.get_tweet_full_length(tweet)
        status = CLIENT.status(tweet, tweet_mode: "extended")

        if status.truncated? && status.attrs[:extended_tweet]
            # Streaming API, and REST API default
            t = status.attrs[:extended_tweet][:full_text]
            return t
        else
            # REST API with extended mode, or untruncated text in Streaming API
            t = status.attrs[:text] || status.attrs[:full_text]
            return t
        end
    end

    def self.task
        # pick a random federal official from database
        rand_id = Random.rand(1...100)
        puts rand_id
        fed = FederalOfficial.find_by(id: rand_id)

        # remove the @ from screen name
        screen_name = fed.screen_name[1, fed.screen_name.length - 1]
        
        # get tweet and full length text from federal official
        tweet_and_text = Bot.get_tweet(screen_name)
        tweet = tweet_and_text[0]
        UsedTweet.create(tweet_id: tweet.id)
        text = tweet_and_text[1]
        truncated = false
        if text.length > 280
            text = text[0,280]
            truncated = true
        end
        puts tweet
        puts text
        # some tweets are longer than 280 characters because the media link (for image) takes up more characters. In that case, it's not currently handled well, but the bot will tweet the first 280 characters. This most likely means the media will not display properly. 

        # tweet the text, save tweet as current_tweet for reply
        current_tweet = Bot.update(text)

        # provide tweet source and party affiliation
        party = fed.party
        if party == "Democrat"
            party = "Democratic"
        end
        reply_text = "Tweet is from @#{screen_name}. #{party} #{fed.position.capitalize} from #{fed.state}"
        if truncated
            reply_text = reply_text + ". Tweet was TRUNCATED. Visit tweet author for full text"
        end
        puts reply_text
        Bot.reply(reply_text, current_tweet, ENV['MY_SCREEN_NAME'])
    end
end
