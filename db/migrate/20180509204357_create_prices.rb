class CreatePrices < ActiveRecord::Migration[5.2]
  def change
    create_table :prices do |t|
      t.decimal :open
      t.decimal :close
      t.decimal :high
      t.decimal :low
      t.decimal :volume
      t.datetime :time
      t.belongs_to :stock
    end
  end
end
