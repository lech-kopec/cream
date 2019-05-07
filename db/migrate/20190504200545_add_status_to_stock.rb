class AddStatusToStock < ActiveRecord::Migration[5.2]
  def change
    add_column :stocks, :status, :integer, default: 0
  end
end
