module Mutations
  class CreateCustomer < Mutations::BaseMutation
    argument :name, String, required: true
    argument :email, String, required: false
    argument :phone, String, required: false
    argument :address, String, required: false

    field :customer, Types::CustomerType, null: true
    field :errors, [String], null: false

    def resolve(name:, email: nil, phone: nil, address: nil)
      customer = context[:current_user].customers.new(
        name: name,
        email: email,
        phone: phone,
        address: address
      )

      if customer.save
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
