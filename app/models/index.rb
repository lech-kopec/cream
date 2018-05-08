class Index < ApplicationRecord
  has_many :stocks
  belongs_to :market

  validates :name, presence: true, uniqueness: true
end
