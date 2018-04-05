require 'graphql'
require_relative 'query_type'
NanoTwitterAPI = GraphQL::Schema.define do
  query QueryType
end
