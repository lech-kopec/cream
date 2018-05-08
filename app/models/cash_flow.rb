class CashFlow < ApplicationRecord
  belongs_to :stock

  validates :year, presence: true
end
