require 'graphql'
Dir["./*.rb"].each {|file| require file}
QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root for this schema"

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
    resolve -> (obj, args, ctx) {
      Tweet.all
    }
  end
end
