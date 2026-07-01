module Mutations
  class DeleteOrder < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      order = context[:current_user].orders.find_by(id: id)
      return { success: false, errors: ["Order not found"] } if order.nil?

      if order.destroy
        {
          success: true,
          errors: []
        }
      else
        {
          success: false,
          errors: order.errors.full_messages
        }
      end
    end
  end
end
