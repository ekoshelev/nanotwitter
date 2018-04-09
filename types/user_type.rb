require 'graphql'
UserType = GraphQL::ObjectType.define do
  name "User"
  description "A User of Nanotwiiter GraphQL"
  field :id, types.ID
  field :name, types.String
  field :email, types.String
  field :password, types.String

  field :tweets do
    type types[TweetType]
    argument :recent, types.Int, default_value: 10
    resolve -> (user, args, ctx) {
    return user.tweets.limit(args[:recent]).reverse
    }
  end

  field :followers do
    type types[UserType]
    resolve -> (user,args,ctx){
      temp = user.followers
      follower_users = []
      temp.each {|f| follower_users << f.follower}
      return follow_users
    }
  end

  field :following do
    type types[UserType]
    resolve -> (user,args,ctx){
      fwrs = user.followers
      following_users = []
      fwrs.each {|f| following_users << f.follower}
      return following_users
    }
  end


end
