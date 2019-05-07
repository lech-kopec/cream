require_relative './dcf_01'

Dcf = StockFrame::Strategies::Dcf_01
describe StockFrame::Strategies::Dcf_01 do
  it 'passes init' do
    x = Dcf.new nil
    expect(x).to be_truthy
  end
end
