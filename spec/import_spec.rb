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
  end

end
