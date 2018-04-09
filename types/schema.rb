require 'graphql'
require_relative 'query_type'
require_relative 'mutation_type'
NanoTwitterAPI = GraphQL::Schema.define do
  query QueryType
  mutation MutationType
end
