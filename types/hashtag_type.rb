require 'graphql'
Dir["./types/*.rb"].each {|file| require file}
Dir["./controllers/*.rb"].each {|file| require file}

HashtagType = GraphQL::ObjectType.define do
  name "Hashtag"
  description "A Hashtag of NanoTwitter GraphQL"

  field :id, types.ID
  field :name, types.String

  field :tweets do
    type types[TweetType]
    argument :recent, types.Int, default_value: 50
    resolve -> (hashtag, args, ctx){
      tags = hashtag.tweets.sort_by{ |k| k["time_created"] }.reverse!
      return tags[0...args[:recent]]
    }
  end

end
