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
    expect(Postcode.first.postcode).to eq("AB1 0AA")
    expect(Postcode.first.area).to eq("AB")
    expect(Postcode.first.outcode).to eq("AB1")
    expect(Postcode.first.incode).to eq("0AA")
    expect(Postcode.first.easting).to eq(385386)
    expect(Postcode.first.northing).to eq(801193)
  end

end
