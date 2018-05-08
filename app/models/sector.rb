class Sector < ApplicationRecord
  belongs_to :market
  has_many :stocks

  validates :name, presence: true, uniqueness: true

end
