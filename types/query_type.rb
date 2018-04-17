require 'graphql'
Dir["./*.rb"].each {|file| require file}
QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root for NanoTwitter's GraphQL Schema"

  field :users do
    type types[UserType]
    resolve -> (obj, args, ctx) {
      User.all
    }
  end

  field :user do
    type UserType
    argument :id, !types.ID
    resolve -> (obj,args,ctx) {
      User.find(args[:id])
    }
  end

  field :tweet do
    type TweetType
    argument :id, !types.ID
    resolve -> (obj,args,ctx) {
      Tweet.find(args[:id])
    }
  end

  field :tweets do
    type types[TweetType]
    argument :recent, types.Int, default_value: 10
    resolve -> (obj, args, ctx) {
      #Tweet.all.limit(args[:recent]).reverse
      tweets= Tweet.all.sort_by{ |k| k["time_created"] }.reverse!
      return tweets[0..args[:recent]]
    }
  end

  field :create_tweet do
    type TweetType

    argument :text, !types.String
    argument :api_token, !types.String

    resolve -> (obj,args,ctx){

      if User.find_by(api_token: args[:api_token]) != nil
        user = User.find_by(api_token: args[:api_token])
        tweet = user.tweets.create(text: args[:text],time_created: Time.now.getutc)
      else
        "Invalid API Token: #{args[:api_token]}"
      end
    }

  end
end
