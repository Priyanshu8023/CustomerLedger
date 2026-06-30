module Mutations
  class UpdateCustomer < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :email, String, required: false
    argument :phone, String, required: false
    argument :address, String, required: false

    field :customer, Types::CustomerType, null: true
    field :errors, [String], null: false

    def resolve(id:, **attributes)
      customer = context[:current_user].customers.find_by(id: id)
      return { customer: nil, errors: ["Customer not found"] } if customer.nil?

      if customer.update(attributes.compact)
        {
          customer: customer,
          errors: []
        }
      else
        {
          customer: nil,
          errors: customer.errors.full_messages
        }
      end
    end
  end
end
