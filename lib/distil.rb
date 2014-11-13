module Distiller
  class Distil

    def self.perform
      response = HTTParty.get(ENV['ERNEST_ADDRESS_ENDPOINT']).parsed_response
      pages = response["pages"].to_i

      1.upto(pages) do |i|
        response = HTTParty.get("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=#{i}").parsed_response
        response['addresses'].each do |address|
          street = get_street(address)
          locality = get_locality(address)
          town = get_town(address)
          postcode = get_postcode(address)

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

    def self.get_locality(address)
      Locality.where(name: address['locality']['name']).first
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
      elsif street.count == 0
        street = Street.create(name: address['street']['name'])
      elsif street.count > 1
        location = address['street']['geometry'].nil? ? nil : address['street']['geometry']['coordinates']
        if location.nil?
          street = street.first # If we don't have a geometry, we'll have to return a best guess for now
        else
          street = Street.where(name: address['street']['name'], location: location).first
        end
      end
      return street
    end

  end
end
