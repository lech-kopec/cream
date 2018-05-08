class Market < ApplicationRecord
  has_many :stocks
  has_many :sectors
  has_many :indices

  validates :name, presence: true, uniqueness: true
end
