module Distiller
  module Helpers

    def en_to_ll(easting, northing)
      ll = Breasal::EastingNorthing.new(easting: easting.to_i, northing: northing.to_i).to_wgs84
      {
        lat: ll[:latitude],
        lng: ll[:longitude]
      }
    end

    def current_sha
      if ENV['MONGOID_ENVIRONMENT'] == "production"
        @current_sha ||= begin
          heroku = PlatformAPI.connect_oauth(ENV['HEROKU_TOKEN'])
          slug_id = heroku.release.list(ENV['HEROKU_APP']).last["slug"]["id"]
          heroku.slug.info(ENV['HEROKU_APP'], slug_id)["commit"]
        end
      else
        @current_sha ||= `git rev-parse HEAD`.strip
      end
    end

  end
end
