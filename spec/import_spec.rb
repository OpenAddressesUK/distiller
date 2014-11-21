require 'spec_helper'

describe Distiller::Import do

  it "creates towns", :vcr do
    Timecop.freeze("2014-01-01")
    allow(Distiller::Import).to receive(:current_sha).and_return("sdasdasdasd")

    Distiller::Import.towns

    expect(Town.all.count).to eq(1501)

    expect(Town.first.provenance).to eq({
      "activity" => {
        "executed_at" => Time.parse("2014-01-01").utc,
        "processing_scripts" => "https://github.com/OpenAddressesUK/distiller",
        "derived_from" => [
          {
            "name" => "Wikipedia list of Post Towns in the United Kingdom",
            "type" => "Source",
            "urls" => [
              "https://en.wikipedia.org/wiki/List_of_post_towns_in_the_United_Kingdom"
            ],
            "downloaded_at" => Time.parse("2014-01-01").utc,
            "description_url" => "https://en.wikipedia.org/wiki/List_of_post_towns_in_the_United_Kingdom",
            "processing_script" => "https://github.com/OpenAddressesUK/distiller/tree/sdasdasdasd/lib/import.rb"
          }
        ]
      }
    })

    Timecop.return
  end

  it "creates postcodes" do
    Timecop.freeze("2014-01-01")
    allow(Distiller::Import).to receive(:current_sha).and_return("sdasdasdasd")

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
    expect(postcode.lat_lng.y.to_s).to match /\-2\.24283/
    expect(postcode.lat_lng.x.to_s).to match /57\.10147/

    expect(postcode.provenance).to eq({
      "activity" => {
        "executed_at" => Time.parse("2014-01-01").utc,
        "processing_scripts" => "https://github.com/OpenAddressesUK/distiller",
        "derived_from" => [
          {
            "name" => "ONS Postcode Directory (UK) Aug 2014",
            "type" => "Source",
            "urls" => [
              "https://geoportal.statistics.gov.uk/Docs/PostCodes/ONSPD_AUG_2014_csv.zip"
            ],
            "downloaded_at" => Time.parse("2014-01-01").utc,
            "description_url" => "https://geoportal.statistics.gov.uk/geoportal/catalog/search/resource/details.page?uuid=%7B473A5770-FB1B-4C1A-AEEC-5DC056E5EC7F%7D",
            "processing_script" => "https://github.com/OpenAddressesUK/distiller/tree/sdasdasdasd/lib/import.rb"
          }
        ]
      }
    })

    Timecop.return
  end

  it "creates localities" do
    Timecop.freeze("2014-01-01")
    allow(Distiller::Import).to receive(:current_sha).and_return("sdasdasdasd")

    stub_request(:any, "https://github.com/OpenAddressesUK/IPN_2012/blob/master/IPN2012.csv?raw=true").
      to_return(body: File.open(File.join(Dir.pwd, "spec", "fixtures", "IPN2012.csv")))

    Distiller::Import.localities

    expect(Locality.all.count).to eq(100)

    locality = Locality.where(name: "Woughton").first

    expect(locality.name).to eq("Woughton")
    expect(locality.authority).to eq("E06000042")
    expect(locality.lat_lng.y.to_s).to match /\-0\.73233/
    expect(locality.lat_lng.x.to_s).to match /52\.03450/

    expect(locality.provenance).to eq({
      "activity" => {
        "executed_at" => Time.parse("2014-01-01").utc,
        "processing_scripts" => "https://github.com/OpenAddressesUK/distiller",
        "derived_from" => [
          {
            "name" => "Office for National Statistics Index of Place Names 2012 (E+W)",
            "type" => "Source",
            "urls" => [
              "https://github.com/OpenAddressesUK/IPN_2012/blob/master/IPN2012.csv?raw=true"
            ],
            "downloaded_at" => Time.parse("2014-01-01").utc,
            "description_url" => "https://geoportal.statistics.gov.uk/geoportal/catalog/search/resource/details.page?uuid=%7BCDE30768-6419-4730-B434-B8B46BF9CBB1%7D",
            "processing_script" => "https://github.com/OpenAddressesUK/distiller/tree/sdasdasdasd/lib/import.rb"
          }
        ]
      }
    })

    Timecop.return
  end

  it "creates streets" do
    Timecop.freeze("2014-01-01")
    allow(Distiller::Import).to receive(:current_sha).and_return("sdasdasdasd")

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
    expect(street.lat_lng.x.to_s).to match /51.1200/
    expect(street.lat_lng.y.to_s).to match /0\.0009/

    expect(street.provenance).to eq({
      "activity" => {
        "executed_at" => Time.parse("2014-01-01").utc,
        "processing_scripts" => "https://github.com/OpenAddressesUK/distiller",
        "derived_from" => [
          {
            "name" => "OS Locator",
            "type" => "Source",
            "urls" => [
              "https://github.com/OpenAddressesUK/OS_Locator/blob/gh-pages/OS_Locator2014_2_OPEN_xaa.txt?raw=true"
            ],
            "downloaded_at" => Time.parse("2014-01-01").utc,
            "description_url" => "http://www.ordnancesurvey.co.uk/business-and-government/products/os-locator.html",
            "processing_script" => "https://github.com/OpenAddressesUK/distiller/tree/sdasdasdasd/lib/import.rb"
          }
        ]
      }
    })

    Timecop.return
  end

end
