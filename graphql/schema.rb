require 'graphql'
require_relative 'query'
NTAppSchema = GraphQL::Schema.define do
  query QueryType
end
