module Mutations
  class UpdateOrder < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :status, String, required: false
    argument :total_amount, Float, required: false
    argument :order_date, GraphQL::Types::ISO8601Date, required: false
    argument :notes, String, required: false

    field :order, Types::OrderType, null: true
    field :errors, [String], null: false

    def resolve(id:, **attributes)
      order = context[:current_user].orders.find_by(id: id)
      return { order: nil, errors: ["Order not found"] } if order.nil?

      if order.update(attributes.compact)
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
