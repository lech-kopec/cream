class CreateIncomeStatements < ActiveRecord::Migration[5.2]
  def change
    create_table :income_statements do |t|
      t.integer :year
      t.integer :quarter
      t.decimal :revenue
      t.decimal :cost_of_revenue
      t.decimal :selling_cost
      t.decimal :administrative_cost
      t.decimal :gross_profit
      t.decimal :other_operating_income
      t.decimal :other_operating_cost
      t.decimal :operating_protif
      t.decimal :financial_income
      t.decimal :financial_cost
      t.decimal :other_income
      t.decimal :income_before_tax
      t.decimal :extra_item
      t.decimal :net_profit
      t.belongs_to :stock
    end
  end
end
