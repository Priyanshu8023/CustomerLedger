module Types
  class DashboardType < Types::BaseObject
    field :total_customers, Integer, null: false
    field :total_orders, Integer, null: false
    field :completed_orders, Integer, null: false
    field :pending_orders, Integer, null: false
    field :total_revenue, Float, null: false
    field :today_orders, Integer, null: false
    field :recent_orders, [Types::OrderType], null: false
  end
end
