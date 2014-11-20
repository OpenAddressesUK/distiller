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
        "name" => "TEST ROAD",
        "geometry" => {
          "type" => "Point",
          "coordinates" => [406043, 286921]
        }
      },
      "locality" => {
        "name" => "KINGS HEATH"
      },
      "town" => {
        "name" => "BIRMINGHAM"
      },
      "postcode" => {
        "name" => "B1 2NN",
        "geometry" => {
          "type" => "Point",
          "coordinates" => [406137,286927]
        }
      }
    }

  end

  context "distiller" do

    before(:each) do
      json = JSON.parse(File.read(File.join(File.dirname(__FILE__), "fixtures", "one-page.json")))

      json['addresses'].each do |address|
        # FactoryGirl.create(:street, name: address['street']['name'])
        #FactoryGirl.create(:locality, name: address['locality']['name'])
        FactoryGirl.create(:town, name: address['town']['name'])
        #FactoryGirl.create(:postcode, name: address['postcode']['name'])
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
        to_return(body: File.read(File.join(File.dirname(__FILE__), "fixtures", "page-1.json")),
                  headers: {"Content-Type" => "application/json"})

      (1..5).each do |num|
        stub_request(:get, "#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=#{num}").
          to_return(body: File.read(File.join(File.dirname(__FILE__), "fixtures", "page-#{num}.json")),
                    headers: {"Content-Type" => "application/json"})
      end

      Distiller::Distil.perform

      expect(Address.count).to eq 125
    end

    it "steps over pages of addresses" do
      stub_request(:get, /#{ENV['ERNEST_ADDRESS_ENDPOINT']}(\?page=[0-9]+)?/).
        to_return(body: File.read(File.join(File.dirname(__FILE__), "fixtures", "multi-page.json")),
                  headers: {"Content-Type" => "application/json"})

      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=1").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=6").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=11").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=16").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=21").and_call_original

      Distiller::Distil.perform(nil, 1, 5)
    end

    it "steps over pages of addresses with an odd number" do
      stub_request(:get, /#{ENV['ERNEST_ADDRESS_ENDPOINT']}(\?page=[0-9]+)?/).
        to_return(body: File.read(File.join(File.dirname(__FILE__), "fixtures", "multi-page.json")),
                  headers: {"Content-Type" => "application/json"})

      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=1").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=4").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=7").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=10").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=13").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=16").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=19").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=22").and_call_original
      expect(HTTParty).to receive(:get).with("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=25").and_call_original

      Distiller::Distil.perform(nil, 1, 3)
    end

    it "keeps retrying if it encounters an error" do
      25.times { puts Address.count ; sleep 1 }

      # stub_request(:get, ENV['ERNEST_ADDRESS_ENDPOINT']).
      #   to_return({:status => [500, "Internal Server Error"]}).times(2).then.
      #   to_return(body: File.read(File.join(File.dirname(__FILE__), "fixtures", "one-page.json")),
      #             headers: {"Content-Type" => "application/json"})
      #
      # stub_request(:get, "#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=1").
      #   to_return({:status => [500, "Internal Server Error"]}).times(3).then.
      #   to_return(body: File.read(File.join(File.dirname(__FILE__), "fixtures", "one-page.json")),
      #             headers: {"Content-Type" => "application/json"})
      #
      # allow(Distiller::Distil).to receive(:sleep)
      #
      # expect(Distiller::Distil).to receive(:sleep).with(5).twice
      # expect(Distiller::Distil).to receive(:sleep).with(10).twice
      # expect(Distiller::Distil).to receive(:sleep).with(15).once
      #
      # Distiller::Distil.perform
      #
      # expect(Address.count).to eq 25
    end

  end

  context "get street" do
    it "Identifies streets successfully when there is a single candidate" do
      street = Street.create(name: "TEST ROAD")

      got_street = Distiller::Distil.get_street(@address)

      expect(got_street).to eq(street)
    end

    it "Identifies streets successfully when street is ambiguous" do
      Street.create(name: "TEST ROAD", easting_northing: [186921, 506043])
      street = Street.create(name: "TEST ROAD", easting_northing: [286921, 406043])

      got_street = Distiller::Distil.get_street(@address)

      expect(got_street).to eq(street)
    end

    it "Creates a new street when no candidate is available" do
      address = @address
      address['street']['name'] = "FAKE STREET"
      got_street = Distiller::Distil.get_street(@address)

      expect(got_street.name).to eq("FAKE STREET")
    end

    it "returns a best guess if no geo data is available" do
      5.times do
        Street.create(name: "EVERGREEN TERRACE")
      end

      address = @address
      address['street']['name'] = "EVERGREEN TERRACE"
      address['street']['geometry'] = nil

      got_street = Distiller::Distil.get_street(@address)
      expect(got_street.name).to eq("EVERGREEN TERRACE")
    end

  end

  context "locality" do

    it "Identifies localities successfully" do
      locality = Locality.create(name: "KINGS HEATH")

      got_locality = Distiller::Distil.get_locality(@address, nil)

      expect(got_locality).to eq(locality)
    end


    it "Identifies localities successfully when locality is ambiguous" do
      locality = Locality.create(name: "KINGS HEATH", easting_northing: [407460, 282970])
      Locality.create(name: "KINGS HEATH", easting_northing: [307460, 182970])
      postcode = Postcode.create(
                                  name: @address['postcode']['name'],
                                  easting_northing: [407378, 282153]
                                )

      got_locality = Distiller::Distil.get_locality(@address, postcode)

      expect(got_locality).to eq(locality)
    end

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
