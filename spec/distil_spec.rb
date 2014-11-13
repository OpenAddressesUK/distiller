require 'spec_helper'

describe Distiller::Distil do

  before(:each) do
    @address =  {
      "saon" => {
        "name" => nil
      },
      "paon" => {
        "name" => "123"
      },
      "street" => {
        "name" => "TEST ROAD"
      },
      "locality" => {
        "name" => "KINGS HEATH"
      },
      "town" => {
        "name" => "BIRMINGHAM"
      },
      "postcode" => {
        "name" => "B1 2NN"
      }
    }

  end

  context "distiller" do

    before(:each) do
      json = JSON.parse(File.read(File.join(File.dirname(__FILE__), "fixtures", "one-page.json")))

      json['addresses'].each do |address|
        Street.create(name: address['street']['name'])
        Locality.create(name: address['locality']['name'])
        Town.create(name: address['town']['name'])
        Postcode.create(name: address['postcode']['name'])
      end
    end

    it "imports one page of addresses" do
      stub_request(:get, ENV['ERNEST_ADDRESS_ENDPOINT']).
        to_return(body: File.read(File.join(File.dirname(__FILE__), "fixtures", "one-page.json")),
                  headers: {"Content-Type" => "application/json"})

      stub_request(:get, "#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=1").
        to_return(body: File.read(File.join(File.dirname(__FILE__), "fixtures", "one-page.json")),
                  headers: {"Content-Type" => "application/json"})

      Distiller::Distil.perform

      expect(Address.count).to eq 25

      address = Address.where("street.name" => "PEPPER ROAD").first

      expect(address.pao).to eq("57")
      expect(address.street.name).to eq("PEPPER ROAD")
      expect(address.town.name).to eq("LEEDS")
      expect(address.postcode.name).to eq("LS10 2RU")
    end

    it "imports multiple pages of addresses" do
      stub_request(:get, ENV['ERNEST_ADDRESS_ENDPOINT']).
        to_return(body: File.read(File.join(File.dirname(__FILE__), "fixtures", "multi-page.json")),
                  headers: {"Content-Type" => "application/json"})

      stub_request(:get, /#{ENV['ERNEST_ADDRESS_ENDPOINT']}\?page=./).
        to_return(body: File.read(File.join(File.dirname(__FILE__), "fixtures", "multi-page.json")),
                  headers: {"Content-Type" => "application/json"})

      Distiller::Distil.perform

      expect(Address.count).to eq 125
    end

  end

  it "Identifies localities successfully" do
    locality = Locality.create(name: "KINGS HEATH")

    got_locality = Distiller::Distil.get_locality(@address)

    expect(got_locality).to eq(locality)
  end

  it "Identifies towns successfully" do
    town = Town.create(name: "BIRMINGHAM", area: "B")

    got_town = Distiller::Distil.get_town(@address)

    expect(got_town).to eq(town)
  end

  it "Identifies postcodes successfully" do
    postcode = Postcode.create(name: "B1 2NN")

    got_postcode = Distiller::Distil.get_postcode(@address)

    expect(got_postcode).to eq(postcode)
  end

end
