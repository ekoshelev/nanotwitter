require 'graphql'
TweetType = GraphQL::ObjectType.define do
  name "Tweet"
  description "A Tweet from Nanotwiiter QraphQL test"
  field :id, types.ID
  field :text, types.String

  field :user do
    type UserType
    resolve -> (tweet, args, ctx){
      tweet.user
    }
  end
end
