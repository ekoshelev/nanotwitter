require 'graphql'
Dir["./controllers/*.rb"].each {|file| require file}
Dir["./*.rb"].each {|file| require file}
QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root for NanoTwitter's GraphQL Schema"

  field :user do
    type UserType
    argument :id, types.ID
    argument :name, types.String
    resolve -> (obj,args,ctx) {
      if args[:id] != nil
        User.find(args[:id])
      else
        User.find_by(name: args[:name])
      end
    }
  end

  field :search_tweets do
    type types[TweetType]
    argument :search_term, !types.String
    resolve -> (obj, args, ctx){
      tweet_search = Tweet.all.select {|tweet| tweet.text.include?(args[:search_term])}
      return tweet_search.sort_by{ |k| k["time_created"] }.reverse!
    }
  end

  field :search_users do
    type types[UserType]
    argument :search_term, !types.String
    resolve -> (obj, args, ctx){
      user_search = User.all.select {|user| user.name.include?(args[:search_term])}
    }
  end

  field :tweet do
    type TweetType
    argument :id, !types.ID
    resolve -> (obj,args,ctx) {
      Tweet.find(args[:id])
    }
  end

  field :timeline do
    type types[TweetType]
    argument :recent, types.Int, default_value: 50
    resolve -> (obj, args, ctx) {
      timeclass = ReturnTimeline.new
      tweets = timeclass.return_recent_tweets
      return tweets[0...args[:recent]]
    }
  end

  field :hashtag do
    type HashtagType
    argument :id, types.ID
    argument :tag, types.String
    resolve -> (obj, args, ctx){
      if args[:id] != nil
        Hashtag.find(args[:id])
      else
        Hashtag.find_by(name: args[:tag])
      end
    }
  end

  field :post_tweet do
    type TweetType

    argument :text, !types.String
    argument :api_token, !types.String

    resolve -> (obj,args,ctx){
      tw = TwitterFunctionality.new
      if User.find_by(api_token: args[:api_token]) != nil
        user = User.find_by(api_token: args[:api_token])
        tweet = user.tweets.create(text: args[:text],time_created: Time.now.getutc)
        tw.add_hashtags(tweet)
        tw.add_mentions(tweet)
        return tweet
      else
        tweet = Tweet.new(text: "Invalid API Token: #{args[:api_token]}")
      end
    }

  end
end
