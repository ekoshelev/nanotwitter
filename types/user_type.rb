require 'graphql'
Dir["./controllers/*.rb"].each {|file| require file}

UserType = GraphQL::ObjectType.define do
  name "User"
  description "A User of Nanotwiiter GraphQL"
  field :id, types.ID
  field :name, types.String
  #field :email, types.String
  #field :password, types.String

  field :tweets do
    type types[TweetType]
    argument :recent, types.Int, default_value: 50
    resolve -> (user, args, ctx) {
    return user.tweets.limit(args[:recent]).sort_by{ |k| k["time_created"] }.reverse!
    }
  end

  field :timeline do
    type types[TweetType]
    argument :recent, types.Int, default_value: 50
    resolve -> (user, args, ctx){
      timeclass = ReturnTimeline.new
      timeline = timeclass.return_timeline_by_user(user)
      return timeline[0...args[:recent]]
    }
  end

  field :mentions do
    type types[TweetType]
    argument :recent, types.Int, default_value: 50
    resolve -> (user, args, ctx){
      mentions = user.mentioned.sort_by{ |k| k["time_created"] }.reverse!
      return mentions[0...args[:recent]]
    }
  end

  field :followers do
    type types[UserType]
    resolve -> (user,args,ctx){
      temp = user.followers
      follower_users = []
      temp.each {|f| follower_users << f.follower}
      return follower_users
    }
  end

  field :following do
    type types[UserType]
    resolve -> (user,args,ctx){
      fwrs = user.following
      following_users = []
      fwrs.each {|f| following_users << f.user}
      return following_users
    }
  end


end
