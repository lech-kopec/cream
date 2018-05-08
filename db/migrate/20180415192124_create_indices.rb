class CreateIndices < ActiveRecord::Migration[5.2]
  def change
    create_table :indices do |t|
      t.string :name
      t.belongs_to :market
      t.index :name, unique: true
    end
  end
end
