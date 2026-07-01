module Types
  class CustomerType < Types::BaseObject
    implements Types::NodeType
    field :name, String
    field :email, String
    field :phone, String
    field :address, String
    field :orders, Types::OrderType.connection_type, null: true
  end
end
