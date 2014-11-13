require 'spec_helper'

describe Distiller::Distil do

  it "Identifies localities successfully" do
    locality = Locality.create(name: "KINGS HEATH")

    address =  {
      "saon" => nil,
      "paon" => "123",
      "street" => "TEST ROAD",
      "locality" => "KINGS HEATH",
      "town" => "BIRMINGHAM",
      "postcode" => "B1 2NN",
    }

    got_locality = Distiller::Distil.get_locality(address)

    expect(got_locality).to eq(locality)
  end

  it "Identifies towns successfully" do
    town = Town.create(name: "BIRMINGHAM", area: "B")

    address =  {
      "saon" => nil,
      "paon" => "123",
      "street" => "TEST ROAD",
      "locality" => nil,
      "town" => "BIRMINGHAM",
      "postcode" => "B1 2NN",
    }

    got_town = Distiller::Distil.get_town(address)

    expect(got_town).to eq(town)
  end

  it "Identifies postcodes successfully" do
    postcode = Postcode.create(name: "B1 2NN")

    address =  {
      "saon" => nil,
      "paon" => "123",
      "street" => "TEST ROAD",
      "locality" => nil,
      "town" => "BIRMINGHAM",
      "postcode" => "B12NN",
    }

    got_postcode = Distiller::Distil.get_postcode(address)

    expect(got_postcode).to eq(postcode)
  end

end
