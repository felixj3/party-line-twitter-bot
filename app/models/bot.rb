class Bot < ApplicationRecord
    def self.test
        # puts ENV['test']
        # puts TEST
        puts "in test function"
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
        puts "-------- In self.get_tweet, screen name: #{screen_name} --------"
        user = Bot.get_user(screen_name)
        tweet_array = CLIENT.user_timeline(user, count: 100)
        tweet_array.each do |tweet|
            puts "possible tweet partial text:"
            puts tweet.full_text # isn't actual full_text
            actual_full_text = Bot.get_tweet_full_length(tweet)
            puts "full text:"
            puts actual_full_text
            puts "---------------"
            if tweet.in_reply_to_user_id.is_a?(Twitter::NullObject) && !tweet.text.starts_with?("@") && !tweet.text.starts_with?("RT") && actual_full_text.length <= 280 && UsedTweet.find_by(tweet_id: tweet.id) == nil
                # checks if the tweet is not a reply, not a retweet, under 280 characters, and the bot hasn't tweeted before
                return tweet, actual_full_text
            end
        end
        puts "Unable to find suitable tweet, returning most recent one"
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

    # remove any mentions in given text and convert them to twitter links
    # allows readers to click on link to profile without mentioning the profile
    # e.g. converts "@fjbeast3" -> "twitter.com/fjbeast3"
    def self.remove_mentions(text)
        puts "-------- In self.remove_mentions --------"
        words = text.split
		new_words = words.map { |word|
            # each element of words goes through this block and whatever leaves the block goes into new_words
			if word[0] == "@"
				"twitter.com/#{word[1..]}"
			else
				word
			end
		}
        new_text = new_words.join(" ")
        puts "before:"
        puts text
        puts "after:"
		puts new_text
        return new_text
    end

    def self.task
        puts "-------- In self.task --------"
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
        text = Bot.remove_mentions(tweet_and_text[1]) # removing mentions adds a lot more text since each @ becomes a twitter.com/
        truncated = false
        if text.length > 280
            text = text[0,280]
            truncated = true
        end
        puts "tweet object:"
        puts tweet
        puts "tweet text:"
        puts text
        # some tweets are longer than 280 characters because the media link (for image) takes up more characters. In that case, it's not currently handled well, but the bot will tweet the first 280 characters. This most likely means the media will not display properly. 

        # tweet the text, save tweet as current_tweet for reply
        current_tweet = Bot.update(text)

        # provide tweet source and party affiliation
        party = fed.party
        if party == "Democrat"
            party = "Democratic"
        end
        reply_text = "Tweet is from twitter.com/#{screen_name}. #{party} #{fed.position.capitalize} from #{fed.state}. All @ mentions in original tweet were converted to URLs"
        if truncated
            reply_text = reply_text + ". Tweet was TRUNCATED. Visit tweet author for full text"
        end
        puts "my reply tweet:"
        puts reply_text
        Bot.reply(reply_text, current_tweet, ENV['MY_SCREEN_NAME'])
    end
end
