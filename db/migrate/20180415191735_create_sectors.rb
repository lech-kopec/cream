class CreateSectors < ActiveRecord::Migration[5.2]
  def change
    create_table :sectors do |t|
      t.string :name
      t.string :org_name
      t.belongs_to :market
      t.index :name, unique: true
    end
  end
end
