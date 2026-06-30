module Types
  class CustomerType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :email, String
    field :phone, String
    field :address, String
    field :orders, [Types::OrderType], null: true
  end
end