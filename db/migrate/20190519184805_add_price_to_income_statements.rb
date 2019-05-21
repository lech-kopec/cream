class AddPriceToIncomeStatements < ActiveRecord::Migration[5.2]
  def change
    add_column :income_statements, :price_on_report_date, :decimal, default: 0
  end
end
