class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true 

  validates :email, uniqueness: true

  has_many :customers, dependent: :destroy 
  has_many :orders, dependent: :destroy
end
