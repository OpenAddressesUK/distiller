FactoryGirl.define do

  factory :postcode do
    postcode "AB1 0AA"
    area "AB"
    outcode "AB1"
    incode "0AA"
    easting 385386
    northing 801193
    introduced Date.parse("1980-01-01")
    terminated Date.parse("1996-06-01")
    authority "S12000033"
  end

end
