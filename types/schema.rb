require 'graphql'
require_relative 'query_type'
Schema = GraphQL::Schema.define do
  query QueryType
end
