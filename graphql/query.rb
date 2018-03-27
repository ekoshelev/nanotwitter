require 'graphql'
require_relative 'types/user_type'

QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root of this schema"

  field :users, types[Types::UserType] do
    description "Get a list of users"

    resolve ->(_obj, _args, _ctx) {
      User.all
    }
  end
end
