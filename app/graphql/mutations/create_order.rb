module Mutations
  class CreateOrder < Mutations::BaseMutation
    argument :customer_id, ID, required: true
    argument :total_amount, Float, required: false
    argument :status, String, required: false
    argument :order_date, GraphQL::Types::ISO8601Date, required: false
    argument :notes, String, required: false

    field :order, Types::OrderType, null: true
    field :errors, [String], null: false

    def resolve(customer_id:, **attributes)
      customer = context[:current_user].customers.find_by(id: customer_id)
      return { order: nil, errors: ["Customer not found"] } if customer.nil?

      order = context[:current_user].orders.new(attributes.compact.merge(customer: customer))

      if order.save
        {
          order: order,
          errors: []
        }
      else
        {
          order: nil,
          errors: order.errors.full_messages
        }
      end
    end
  end
end
