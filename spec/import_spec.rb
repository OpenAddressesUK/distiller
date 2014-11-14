require 'spec_helper'

describe Distiller::Import do

  it "creates towns", :vcr do
    Distiller::Import.towns

    expect(Town.all.count).to eq(1501)
  end

  it "creates postcodes" do
    stub_request(:any, "https://geoportal.statistics.gov.uk/Docs/PostCodes/ONSPD_AUG_2014_csv.zip").
      to_return(body: File.open(File.join(Dir.pwd, "spec", "fixtures", "ONSPD_AUG_2014_csv.zip")))

    Distiller::Import.postcodes

    expect(Postcode.all.count).to eq(50)

    postcode = Postcode.where(name: "AB1 0AA").first

    expect(postcode.name).to eq("AB1 0AA")
    expect(postcode.area).to eq("AB")
    expect(postcode.outcode).to eq("AB1")
    expect(postcode.incode).to eq("0AA")
    expect(postcode.easting).to eq(385386)
    expect(postcode.northing).to eq(801193)
    expect(postcode.introduced).to eq(Date.parse("1980-01-01"))
    expect(postcode.terminated).to eq(Date.parse("1996-06-01"))
    expect(postcode.authority).to eq("S12000033")
    expect(postcode.location.y.to_s).to match /\-2\.24283/
    expect(postcode.location.x.to_s).to match /57\.10147/
  end

  it "creates localities" do
    stub_request(:any, "https://github.com/OpenAddressesUK/IPN_2012/blob/master/IPN2012.csv?raw=true").
      to_return(body: File.open(File.join(Dir.pwd, "spec", "fixtures", "IPN2012.csv")))

    Distiller::Import.localities

    expect(Locality.all.count).to eq(100)

    locality = Locality.where(name: "Woughton").first

    expect(locality.name).to eq("Woughton")
    expect(locality.authority).to eq("E06000042")
    expect(locality.location.y.to_s).to match /\-0\.73233/
    expect(locality.location.x.to_s).to match /52\.03450/
  end

  it "creates streets" do
    ("a".."d").each do |letter|
      stub_request(:any, "https://github.com/OpenAddressesUK/OS_Locator/blob/gh-pages/OS_Locator2014_2_OPEN_xa#{letter}.txt?raw=true").
        to_return(body: File.open(File.join(Dir.pwd, "spec", "fixtures", "OS_Locator2014_2_OPEN_xa#{letter}.txt")))
    end

    Distiller::Import.streets

    expect(Street.all.count).to eq(40)

    street = Street.where(name: "BUCKINGHAM DRIVE").first

    expect(street.name).to eq("BUCKINGHAM DRIVE")
    expect(street.settlement).to eq("East Grinstead")
    expect(street.locality).to eq("East Grinstead")
    expect(street.authority).to eq("Mid Sussex District")
    expect(street.location.x.to_s).to match /51.1200/
    expect(street.location.y.to_s).to match /0\.0009/
  end

end
