require_relative 'dcf_01'
require_relative '../frame'
require 'byebug'

Dcf = ::StockFrames::Strategies::Dcf_01

obj = {'ticker' => 'KGH',
       'cash' => [1,2,3],
       'income_before_tax' => [1,2,3],
       'amortization' => [1,2,3],
       'capex' => [1,2,3],
       'assets' => [1,3,4],
       'short_term_liabilities' => [1,2,3],
}

stock_frames = ::StockFrames::Frame.new obj

model = Dcf.new stock_frames

describe ::StockFrames::Strategies::Dcf_01 do

  it 'passes init' do
    expect(model).to be_truthy
    expect(stock_frames.ticker).to eq 'KGH'
  end

  it 'should calc average cash' do
    expect(stock_frames.cash.sum).to eq(6)
  end

  it 'calculate free cash flow' do
    fcf = model.free_cash_flow.round(2)
    expect(fcf).to eq(2.43)
  end

end
