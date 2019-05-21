# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_19_184805) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "balance_sheets", force: :cascade do |t|
    t.integer "year"
    t.integer "quarter"
    t.decimal "fixed_assets"
    t.decimal "intangible"
    t.decimal "ppe"
    t.decimal "long_term_receivables"
    t.decimal "long_term_investments"
    t.decimal "other_fixed_assets"
    t.decimal "assets"
    t.decimal "reserves"
    t.decimal "short_term_receivables"
    t.decimal "short_term_investments"
    t.decimal "cash"
    t.decimal "other_assets"
    t.decimal "equity_capital"
    t.decimal "basic_capital"
    t.decimal "reserve_fund"
    t.decimal "long_term_liabilities"
    t.decimal "deliveries_services"
    t.decimal "credits_loans"
    t.decimal "debt_securities"
    t.decimal "leasing"
    t.decimal "other_long_terml_liabilities"
    t.decimal "short_term_liabilities"
    t.decimal "short_term_deliveries_services"
    t.decimal "short_term_credit_loans"
    t.decimal "short_term_debt_securities"
    t.decimal "short_term_leasing"
    t.decimal "other_short_term_liabilies"
    t.decimal "accrued_expenses"
    t.bigint "stock_id"
    t.index ["id", "year", "quarter"], name: "id_year_idx", unique: true
    t.index ["stock_id", "year", "quarter"], name: "year_idx", unique: true
    t.index ["stock_id"], name: "index_balance_sheets_on_stock_id"
  end

  create_table "cash_flows", force: :cascade do |t|
    t.integer "year"
    t.integer "quarter"
    t.decimal "operating_cash_flow"
    t.decimal "amortization"
    t.decimal "investing_cash_flow"
    t.decimal "capex"
    t.decimal "financial_cash_flow"
    t.decimal "shares_issue"
    t.decimal "dividend"
    t.decimal "total_cash_flow"
    t.bigint "stock_id"
    t.index ["id", "year", "quarter"], name: "cf_id_year_idx", unique: true
    t.index ["stock_id"], name: "index_cash_flows_on_stock_id"
  end

  create_table "income_statements", force: :cascade do |t|
    t.integer "year"
    t.integer "quarter"
    t.decimal "revenue"
    t.decimal "cost_of_revenue"
    t.decimal "selling_cost"
    t.decimal "administrative_cost"
    t.decimal "gross_profit"
    t.decimal "other_operating_income"
    t.decimal "other_operating_cost"
    t.decimal "operating_protif"
    t.decimal "financial_income"
    t.decimal "financial_cost"
    t.decimal "other_income"
    t.decimal "income_before_tax"
    t.decimal "extra_item"
    t.decimal "net_profit"
    t.bigint "stock_id"
    t.decimal "price_on_report_date", default: "0.0"
    t.index ["id", "year", "quarter"], name: "_is_id_year_idx", unique: true
    t.index ["stock_id"], name: "index_income_statements_on_stock_id"
  end

  create_table "indices", force: :cascade do |t|
    t.string "name"
    t.bigint "market_id"
    t.index ["market_id"], name: "index_indices_on_market_id"
    t.index ["name"], name: "index_indices_on_name", unique: true
  end

  create_table "markets", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_markets_on_name", unique: true
  end

  create_table "prices", force: :cascade do |t|
    t.decimal "open"
    t.decimal "close"
    t.decimal "high"
    t.decimal "low"
    t.decimal "volume"
    t.datetime "time"
    t.bigint "stock_id"
    t.index ["stock_id"], name: "index_prices_on_stock_id"
  end

  create_table "sectors", force: :cascade do |t|
    t.string "name"
    t.string "org_name"
    t.bigint "market_id"
    t.index ["market_id"], name: "index_sectors_on_market_id"
    t.index ["name"], name: "index_sectors_on_name", unique: true
  end

  create_table "stocks", force: :cascade do |t|
    t.string "ticker"
    t.string "name"
    t.decimal "shares"
    t.string "isin"
    t.date "debut"
    t.string "website"
    t.bigint "market_id"
    t.bigint "sector_id"
    t.bigint "index_id"
    t.text "comment"
    t.decimal "rating"
    t.integer "status", default: 0
    t.index ["index_id"], name: "index_stocks_on_index_id"
    t.index ["market_id"], name: "index_stocks_on_market_id"
    t.index ["sector_id"], name: "index_stocks_on_sector_id"
    t.index ["ticker"], name: "index_stocks_on_ticker", unique: true
  end

end
