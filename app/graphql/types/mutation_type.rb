# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_customer, mutation: Mutations::CreateCustomer
    field :update_customer, mutation: Mutations::UpdateCustomer
    field :delete_customer, mutation: Mutations::DeleteCustomer
    field :create_order, mutation: Mutations::CreateOrder
    field :update_order, mutation: Mutations::UpdateOrder
    field :delete_order, mutation: Mutations::DeleteOrder
  end
end
