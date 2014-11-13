module Distiller
  class Distil

    def self.perform
      response = HTTParty.get(ENV['ERNEST_ADDRESS_ENDPOINT']).parsed_response
      pages = response["pages"].to_i

      1.upto(pages) do |i|
        response = HTTParty.get("#{ENV['ERNEST_ADDRESS_ENDPOINT']}?page=#{i}").parsed_response
        response['addresses'].each do |address|
          town = get_town(address['town'])
          # Address.create(
          #   sao: address['saon'],
          #   pao: address['paon'],
          #   street: address['street'],
          #   locality: address['locality'],
          #   town: address['town'],
          #   postcode: address['postcode']
          # )
        end
      end
    end

    def self.get_locality(address)
      Locality.where(name: address['locality']).first
    end

    def self.get_town(address)
      Town.where(name: address['town']).first
    end

    def self.get_postcode(address)
      postcode = UKPostcode.new(address['postcode'])
      Postcode.where(postcode: postcode.norm).first
    end

  end
end
