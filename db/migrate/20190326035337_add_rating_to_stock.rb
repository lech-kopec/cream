class AddRatingToStock < ActiveRecord::Migration[5.2]
  def change
    add_column :stocks, :rating, :decimal
  end
end
