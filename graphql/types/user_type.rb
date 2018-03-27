require 'graphql'

  UserType = GraphQL::ObjectType.define do
    name 'User'
    description 'Resembles a User Object Type'

    field :id, !types.ID
    field :name, types.String
    field :email, types.String
    field :password, types.String
  end
