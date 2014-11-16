module Distiller
  class Distil

    extend Distiller::Helpers

    def self.perform(pages = nil)
      response = HTTParty.get(ENV['ERNEST_ADDRESS_ENDPOINT']).parsed_response
      pages = (pages || response["pages"]).to_i

      1.upto(pages) do |i|
        response = HTTParty.get("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=#{i}").parsed_response
        response['addresses'].each do |address|
          postcode = get_postcode(address)

          street = get_street(address)
          locality = get_locality(address, postcode)
          town = get_town(address)

          Address.create(
            sao: address['saon']['name'],
            pao: address['paon']['name'],
            street: street,
            locality: locality,
            town: town,
            postcode: postcode
          )
        end
      end
    end

    def self.get_locality(address, postcode)
      return nil if address['locality']['name'].nil?

      locality = Locality.where(name: address['locality']['name'])

      if locality.count > 1
        locality = locality.geo_near(postcode.location.to_a)
      end

      return locality.first
    end

    def self.get_town(address)
      Town.where(name: address['town']['name']).first
    end

    def self.get_postcode(address)
      postcode = UKPostcode.new(address['postcode']['name'])
      Postcode.where(name: postcode.norm).first
    end

    def self.get_street(address)
      street = Street.where(name: address['street']['name'])

      if street.count == 1
        street = street.first
      elsif street.count > 1
        location = address['street']['geometry'].nil? ? nil : address['street']['geometry']['coordinates']
        if location.nil?
          street = street.first # If we don't have a geometry, we'll have to return a best guess for now
        else
          ll = en_to_ll(location[0], location[1])
          street = Street.where(name: address['street']['name'], location: [ll[:lat], ll[:lng]]).first
        end
      elsif street.count == 0
        street = Street.create(name: address['street']['name']) # If there are no streets, create one
      end

      return street
    end

  end
end
