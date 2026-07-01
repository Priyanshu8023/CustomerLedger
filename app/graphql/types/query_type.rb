module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Paginated list of all customers for the logged-in user
    field :customers, Types::CustomerType.connection_type, null: false

    # Paginated list of all orders for the logged-in user
    field :orders, Types::OrderType.connection_type, null: false

    # Fetch a single customer by database ID (replaces GET /customers/:id)
    field :customer, Types::CustomerType, null: true do
      argument :id, ID, required: true
    end

    # Customer summary with order stats (replaces GET /customers/:id/summary)
    field :customer_summary, Types::CustomerSummaryType, null: true do
      argument :id, ID, required: true
    end

    # Overall orders summary (replaces GET /orders/summary)
    field :orders_summary, Types::OrdersSummaryType, null: false

    # Dashboard overview (replaces GET /dashboard)
    field :dashboard, Types::DashboardType, null: false

    # --- Resolvers ---

    def customers
      context[:current_user].customers
    end

    def orders
      context[:current_user].orders
    end

    def customer(id:)
      context[:current_user].customers.find_by(id: id)
    end

    def customer_summary(id:)
      customer = context[:current_user].customers.find_by(id: id)
      return nil if customer.nil?

      orders = customer.orders

      {
        customer_id: customer.id,
        total_orders: orders.count,
        completed_orders: orders.where(status: "Completed").count,
        pending_orders: orders.where(status: "Pending").count,
        total_amount: orders.sum(:total_amount),
        last_order_date: orders.maximum(:order_date),
        recent_orders: orders.order(created_at: :desc).limit(5)
      }
    end

    def orders_summary
      orders = context[:current_user].orders

      {
        total_orders: orders.count,
        completed_orders: orders.where(status: "Completed").count,
        pending_orders: orders.where(status: "Pending").count,
        total_revenue: orders.sum(:total_amount),
        today_orders: orders.where(order_date: Date.current).count
      }
    end

    def dashboard
      user = context[:current_user]
      orders = user.orders

      {
        total_customers: user.customers.count,
        total_orders: orders.count,
        completed_orders: orders.where(status: "Completed").count,
        pending_orders: orders.where(status: "Pending").count,
        total_revenue: orders.sum(:total_amount),
        today_orders: orders.where(order_date: Date.current).count,
        recent_orders: orders.includes(:customer).order(created_at: :desc).limit(5)
      }
    end
  end
end
