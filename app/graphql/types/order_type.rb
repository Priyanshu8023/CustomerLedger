module Types
  class OrderType < Types::BaseObject
    field :id, ID, null: false
    field :order_number, String
    field :status, String
    field :total_amount, Float
    field :order_date, GraphQL::Types::ISO8601Date
    field :notes, String
    field :customer, Types::CustomerType
  end
end
