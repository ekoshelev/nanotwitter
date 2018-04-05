require 'graphql'
UserType = GraphQL::ObjectType.define do
  name "User"
  description "A User of Nanotwiiter GraphQL test"
  field :id, types.ID
  field :name, types.String
  field :email, types.String
  field :password, types.String

  field :tweets do
    type types[TweetType]
    resolve -> (user, args, ctx) {
    user.tweets
    }
  end
end
