module Types
  class OrdersSummaryType < Types::BaseObject
    field :total_orders, Integer, null: false
    field :completed_orders, Integer, null: false
    field :pending_orders, Integer, null: false
    field :total_revenue, Float, null: false
    field :today_orders, Integer, null: false
  end
end
