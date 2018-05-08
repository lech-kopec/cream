class CreateBalanceSheets < ActiveRecord::Migration[5.2]
  def change
    create_table :balance_sheets do |t|
      t.integer :year
      t.integer :quarter
      t.decimal :fixed_assets
      t.decimal :intangible
      t.decimal :ppe
      t.decimal :long_term_receivables
      t.decimal :long_term_investments
      t.decimal :other_fixed_assets
      t.decimal :assets
      t.decimal :reserves
      t.decimal :short_term_receivables
      t.decimal :short_term_investments
      t.decimal :cash
      t.decimal :other_assets
      t.decimal :equity_capital
      t.decimal :basic_capital
      t.decimal :reserve_fund
      t.decimal :long_term_liabilities
      t.decimal :deliveries_services
      t.decimal :credits_loans
      t.decimal :debt_securities
      t.decimal :leasing
      t.decimal :other_long_terml_liabilities
      t.decimal :short_term_liabilities
      t.decimal :short_term_deliveries_services
      t.decimal :short_term_credit_loans
      t.decimal :short_term_debt_securities
      t.decimal :short_term_leasing
      t.decimal :other_short_term_liabilies
      t.decimal :accrued_expenses
      t.belongs_to :stock
    end
  end
end
