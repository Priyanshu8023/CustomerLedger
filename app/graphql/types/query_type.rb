module Types
  class QueryType < Types::BaseObject
    field :customers, [Types::CustomerType], null: false
    field :orders, [Types::OrderType], null: false

    def customers 
      context[:current_user].customers
    end

    def orders
      context[:current_user].orders
    end
  end
end
