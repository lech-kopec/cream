class CreateStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :stocks do |t|
      t.string :ticker
      t.string :name
      t.decimal :shares
      t.string :isin
      t.date :debut
      t.string :website
      t.belongs_to :market
      t.belongs_to :sector
      t.belongs_to :index
      t.index :ticker, unique: true
    end
  end
end
