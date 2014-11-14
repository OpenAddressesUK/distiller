module Distiller
  module Helpers

    def en_to_ll(easting, northing)
      ll = Breasal::EastingNorthing.new(easting: easting.to_i, northing: northing.to_i).to_wgs84
      {
        lat: ll[:latitude],
        lng: ll[:longitude]
      }
    end

  end
end
