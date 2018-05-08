class Stock < ApplicationRecord
  belongs_to :market

  has_many :income_statements
  has_many :balance_sheets
  has_many :cash_flows

  validates :name, presence: true, uniqueness: true

  scope :not_banks, lambda { id = Sector.find_by_name('Banks'); where("sector_id != ?", id) }
end
