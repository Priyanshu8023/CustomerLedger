module Mutations
  class DeleteCustomer < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      customer = context[:current_user].customers.find_by(id: id)
      return { success: false, errors: ["Customer not found"] } if customer.nil?

      if customer.destroy
        {
          success: true,
          errors: []
        }
      else
        {
          success: false,
          errors: customer.errors.full_messages
        }
      end
    end
  end
end
