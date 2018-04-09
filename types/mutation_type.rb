require 'graphql'
Dir["./*.rb"].each {|file| require file}
MutationType = GraphQL::ObjectType.define do
  name "Mutation"
  description "The mutation root for NanoTwitter's GraphQL Schema"

end
