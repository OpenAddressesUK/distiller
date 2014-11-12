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

    postcode = Postcode.where(postcode: "AB1 0AA").first

    expect(postcode.postcode).to eq("AB1 0AA")
    expect(postcode.area).to eq("AB")
    expect(postcode.outcode).to eq("AB1")
    expect(postcode.incode).to eq("0AA")
    expect(postcode.easting).to eq(385386)
    expect(postcode.northing).to eq(801193)
    expect(postcode.introduced).to eq(Date.parse("1980-01-01"))
    expect(postcode.terminated).to eq(Date.parse("1996-06-01"))
    expect(postcode.authority).to eq("S12000033")
    expect(postcode.location.y).to eq(801193.0)
    expect(postcode.location.x).to eq(385386.0)
  end

  it "creates settlements" do
    stub_request(:any, "https://github.com/OpenAddressesUK/IPN_2012/blob/master/IPN2012.csv?raw=true").
      to_return(body: File.open(File.join(Dir.pwd, "spec", "fixtures", "IPN2012.csv")))

    Distiller::Import.settlements

    expect(Settlement.all.count).to eq(100)

    settlement = Settlement.where(name: "Woughton").first

    expect(settlement.name).to eq("Woughton")
    expect(settlement.authority).to eq("E06000042")
    expect(settlement.location.y).to eq(238102.0)
    expect(settlement.location.x).to eq(487056.0)
  end

end
