class Price < ApplicationRecord
  belongs_to :stock

  scope :latest, lambda { order(time: :desc).first }
  scope :not_banks, lambda { id = Sector.find_by_name('Banks'); where("sector_id != ?", id) }
end
