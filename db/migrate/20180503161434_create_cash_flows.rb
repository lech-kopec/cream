class CreateCashFlows < ActiveRecord::Migration[5.2]
  def change
    create_table :cash_flows do |t|
      t.integer :year
      t.integer :quarter
      t.decimal :operating_cash_flow
      t.decimal :amortization
      t.decimal :investing_cash_flow
      t.decimal :capex
      t.decimal :financial_cash_flow
      t.decimal :shares_issue
      t.decimal :dividend
      t.decimal :total_cash_flow
      t.belongs_to :stock
    end
  end
end
