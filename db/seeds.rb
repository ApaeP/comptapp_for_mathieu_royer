user = User.create!(
  id: 1,
  email: "paulportier@gmail.com",
  first_name: "Paul",
  last_name: "Portier",
  provider: "github",
  uid: "54004476",
  password: 'azerty',
  github_name: "ApaeP",
  avatar_url: "https://avatars.githubusercontent.com/u/54004476?v=4",
  business_name: "",
  business_address: "53 quai Charles Pasqua\n92300 Levallois-Perret",
  business_country: "France",
  siret: "800 000 000 00001",
  iban: "FR76 0000 0000 0000 0000 0000 111",
  bic: "CMCIFRPP"
)
puts "#{User.count} users created"

# CLIENTS
clients = [
  [ 'Le Wagon', "24 rue Louis Blanc\n75010, Paris", "France", "794 949 917 RCS Paris", '' ],
  [ 'Main Verte Consulting ApS', "Carit Etlars Vej 15, 1. th.\n1814 Frederiksberg C", "Denmark", "0045 50315053", 'Tax ID DK40614559' ],
  [ 'Kio Software', "143 av. Jean-Baptiste Clément\n92100, Boulogne-Billancourt", "France", "Nanterre B 852 615 947", '852 615 947 00011' ],
  [ 'Chez Maurice Production', "25 rue de la Libération\n92500 Rueil-Malmaison", "France", "Nanterre B 881 292 676", '881 292 676 00023' ],
  [ 'Denise Omer Design', "11, rue Tronchet\n75008 Paris", "France", "", '527 504 450 00018' ],
]

clients.each do |e|
  Client.create!(
    user: user,
    name: e[0],
    address: e[1],
    country: e[2],
    rcs: e[3],
    siret: e[4]
  )
end
puts "#{Client.count} clients created"
# CLIENTS END

if Rails.env.development?
  require_relative 'custom/2020'
  require_relative 'custom/2021_q1'
  require_relative 'custom/2021_q2'
  require_relative 'custom/2021_q3'
  require_relative 'custom/2021_q4'
  require_relative 'custom/2022_q1'
else
  # INVOICES
  def create_invoice(user:, client:, current_month: false)
    creation_date = current_month ? rand(Time.now.day).days.ago : rand(3.years).seconds.ago
    inv_items_attr = []
    3..10.times do
      inv_items_attr << { name: "#{Faker::Hacker.verb} #{Faker::Hacker.noun}", unit_price_cents: rand(12000..50000).round(-1).to_f, quantity: rand(1..20) }
    end
    Invoice.create!(
      user: user,
      client: client,
      created_at: creation_date,
      name: "#{Faker::Hacker.adjective} #{Faker::Hacker.abbreviation} #{Faker::Hacker.ingverb}",
      description: Faker::Hacker.say_something_smart,
      invoice_items_attributes: inv_items_attr
    )
  end

  Client.find_each do |e|
    5..10.times do
      create_invoice(user: user, client: e)
    end
    create_invoice(user: user, client: e, current_month: true)
  end

  puts "#{Invoice.count} invoices created"
  # INVOICES END
end


