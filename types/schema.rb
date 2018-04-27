require 'graphql'
require './types/user_type.rb'
require './types/tweet_type.rb'
require './types/hashtag_type.rb'
require './types/query_type.rb'
#require_relative 'mutation_type'
NanoTwitterAPI = GraphQL::Schema.define do
  query QueryType
  mutation MutationType
end
