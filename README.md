# Rails Twitter Bot

## About

Every hour, a random US Senator’s most recent tweet is tweeted by this bot. After elections in November 2020, the tweets will be pulled from all members of the legislative and executive branch. Check out the tweets at [@toethepartyline](https://twitter.com/toethepartyline)

## Purpose

### Tech
Hobby project to continue working on using the Rails framework and to learn how to use Heroku. 

### Idea
Nearing election time, tweets have become more and more politicized. The issues and policies that benefit all citizens are no longer bipartisan. In April of 2020, if you read a tweet about wearing masks, what party would it have come from? Why is it so easy to tell? Looking through the bot's profile, what other issues only have support from one side? 

## Code

There is most definitely a better way to make a twitter bot using the Ruby Twitter gem. The rails framework adds a lot of extra files and packages that aren't necessary for running this bot. However, by making a twitter bot with the Rails framework, there is potential to make a website related to this project. 

The twitter bot methods are in the Bot model ```app/models/bot.rb```. Setting up the client is in the twitter initializer ```config/initializers/twitter.rb```. Heroku scheduler will call the task ```rails tweet``` every hour, and the task can be found at  ```lib/tasks/tweet.rake```. 

My .env file has these keys
```
CONSUMER_KEY
CONSUMER_SECRET
ACCESS_TOKEN
ACCESS_TOKEN_SECRET
MY_SCREEN_NAME
DATABASE_URL
```

### Gems
Used these gems: twitter, dotenv, dotenv-rails, roo, and pg
