module Types
  class CustomerSummaryType < Types::BaseObject
    field :customer_id, ID, null: false
    field :total_orders, Integer, null: false
    field :completed_orders, Integer, null: false
    field :pending_orders, Integer, null: false
    field :total_amount, Float, null: false
    field :last_order_date, GraphQL::Types::ISO8601Date, null: true
    field :recent_orders, [Types::OrderType], null: false
  end
end
