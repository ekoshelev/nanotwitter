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
      Tweet.all.limit(args[:recent]).reverse
    }
  end

  field :create_tweet do
    type TweetType

    argument :text, !types.String
    argument :user_id, !types.ID

    resolve -> (obj,args,ctx){

      if User.where(id: args[:user_id]).exists?
        user = User.find_by(id: args[:user_id])
        tweet = user.tweets.create(text: args[:text],time_created: Time.now.getutc)
      else
        "No user under ID #{args[:user_id]}"
      end
    }

  end
end
