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
      Street.where(name: address['street']['name']).first
    end

  end
end
