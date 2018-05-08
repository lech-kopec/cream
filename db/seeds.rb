# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
Market.create([{name: 'GPW'},{name: 'NewConnect'}])

gpw = Market.find_by_name('GPW')
nc = Market.find_by_name('NewConnect')
  
Sector.create([
  {name: 'Banks', org_name: "Banki", market: gpw},
  {name: 'Architecture', org_name: "Budownictwo", market: gpw},
  {name: 'Developers', org_name: "Deweloperzy", market: gpw},
  {name: 'Energy', org_name: "Energetyka", market: gpw},
  {name: 'Finance other', org_name: "Finanse inne", market: gpw},
  {name: 'Retail', org_name: "Handel detaliczny", market: gpw},
  {name: 'Wholesale', org_name: "Handel hurtowy", market: gpw},
  {name: 'Hotels/Restaurants', org_name: "Hotele i restauracje", market: gpw},
  {name: 'IT', org_name: "Informatyka", market: gpw},
  {name: 'Media', org_name: "Media", market: gpw},
  {name: 'Food Industry', org_name: "Przemysł spożywczy", market: gpw},
  {name: 'Light Industry', org_name: "Przemysł lekki", market: gpw},
  {name: 'Wood Industry', org_name: "Przemysł drzewny", market: gpw},
  {name: 'Chemical Industry', org_name: "Przemysł chemiczny", market: gpw},
  {name: 'Pharma Industry', org_name: "Przemysł farmaceutyczny", market: gpw},
  {name: 'Plastics Industry', org_name: "Przemysł tworzyw sztucznych", market: gpw},
  {name: 'Fuel Industry', org_name: "Przemysł paliwowy", market: gpw},
  {name: 'Construction Materials Industry', org_name: "Przemysł materiałów budowlanych", market: gpw},
  {name: 'Electromechanical Industry', org_name: "Przemysł elektromaszynowy", market: gpw},
  {name: 'Metal Industry', org_name: "Przemysł metalowy", market: gpw},
  {name: 'Automotive Industry', org_name: "Przemysł motoryzacyjny", market: gpw},
  {name: 'Raw Material Industry', org_name: "Przemysł surowcowy", market: gpw},
  {name: 'Other Industry', org_name: "Przemysł inne", market: gpw},
  {name: 'Capital Market', org_name: "Rynek kapitałowy", market: gpw},
  {name: 'Telecommunications', org_name: "Telekomunikacja", market: gpw},
  {name: 'Insurance', org_name: "Ubezpieczenia", market: gpw},
  {name: 'Other Services', org_name: "Usługi inne", market: gpw},
])

Sector.create([
  {name: 'Trade', org_name: "Handel", market: nc},
  {name: 'IT', org_name: "Informatyka", market: nc},
  {name: 'Real Estate', org_name: "Nieruchomości", market: nc},
  {name: 'Other Services', org_name: "Usługi inne", market: nc},
  {name: 'Media', org_name: "Media", market: nc},
  {name: 'Financial Services', org_name: "Usługi finansowe", market: nc},
  {name: 'Investments', org_name: "Inwestycje", market: nc},
  {name: 'Technology', org_name: "Technologie", market: nc},
  {name: 'Finance other', org_name: "Finanse inne", market: nc},
  {name: 'Architecture', org_name: "Budownictwo", market: nc},
  {name: 'Leisure', org_name: "Wypoczynek", market: nc},
  {name: 'Telecommunications', org_name: "Telekomunikacja", market: nc},
  {name: 'e-trade', org_name: "e-handel", market: nc},
  {name: 'Recycle', org_name: "Recykling", market: nc},
  {name: 'Health', org_name: "Ochrona zdrowia", market: nc},
  {name: 'Eco-energy', org_name: "Eco-energia", market: nc},
])