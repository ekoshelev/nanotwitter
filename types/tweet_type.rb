require 'graphql'
Dir["./types/*.rb"].each {|file| require file}
TweetType = GraphQL::ObjectType.define do
  name "Tweet"
  description "A Tweet from Nanotwiiter QraphQL test"
  field :id, types.ID
  field :text, types.String
  field :time_created, types.String
  field :retweet_id, types.ID

  field :poster do
    type types.String
    resolve -> (tweet, args, ctx){
      tweet.user.name
    }
  end

  field :user do
    type UserType
    resolve -> (tweet, args, ctx){
      tweet.user
    }
  end

  field :retweeted do
    type types[TweetType]
    resolve -> (tweet, args, ctx){
      tweet.retweeted
    }
  end

  field :retweet do
    type TweetType
    resolve -> (tweet, args, ctx){
      tweet.retweet
    }
  end

end
