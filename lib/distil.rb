module Distiller
  class Distil

    extend Distiller::Helpers

    def self.perform(pages = nil, start_index = 1, step = 1, get_latest = false)
      url = create_url(get_latest)
      pages = get_pages(url, pages)

      start_index.step(pages, step) do |i|
        url.query_values = (url.query_values || {}).merge({"page" => i})
        response = request_with_retries(url.to_s)

        response['addresses'].each do |address|
          create_address(address)
        end
      end
    end

    def self.create_address(address)
      postcode = get_postcode(address)
      street = get_street(address)
      locality = get_locality(address, postcode)
      town = get_town(address)

      a = Address.create(
        sao: address['saon']['name'],
        pao: address['paon']['name'],
        street: street,
        locality: locality,
        town: town,
        postcode: postcode,
        provenance: {
          activity: {
            executed_at: DateTime.now,
            processing_scripts: "https://github.com/OpenAddressesUK/distiller",
            derived_from: derivations(address, [postcode, street, locality, town])
          }
        },
        source: address['provenance']['activity']['derived_from'].first['type']
      )

      if a.valid?
        puts "Address #{a.full_address} created"
      end
    end

    def self.latest
      perform(nil, 1, 1, true)
    end

    def self.create_url(get_latest)
      url = Addressable::URI.parse(ENV['ERNEST_ADDRESS_ENDPOINT'])

      if get_latest == true
        latest = Address.order_by(:updated_at.asc).last.updated_at.utc.iso8601
        url.query_values = { updated_since: latest }
      end

      url
    end

    def self.get_pages(url, pages)
      if pages.nil?
        response = request_with_retries(url.to_s)
        pages = response["pages"]
      end
      pages.to_i
    end

    def self.get_locality(address, postcode)
      return nil if address['locality']['name'].nil?

      locality = Locality.where(name: address['locality']['name'].upcase)

      if locality.count > 1
        locality = Locality.where({
                      name: address['locality']['name'],
                      "easting_northing" => {
                        "$near" => postcode.easting_northing.to_a,
                        "$maxDistance" => 1000
                      }
                  })
      end

      return locality.first
    end

    def self.get_town(address)
      return nil if address['town']['name'].nil?
      Town.where(name: address['town']['name'].upcase).first
    end

    def self.get_postcode(address)
      postcode = UKPostcode.new(address['postcode']['name'])
      Postcode.where(name: postcode.norm).first
    end

    def self.get_street(address)
      return nil if address['street']['name'].nil?
      street = Street.where(name: address['street']['name'].upcase)

      if street.count == 1
        street = street.first
      elsif street.count > 1
        location = address['street']['geometry'].nil? ? nil : address['street']['geometry']['coordinates']
        if location.nil?
          street = street.first # If we don't have a geometry, we'll have to return a best guess for now
        else
          street = Street.where(name: address['street']['name'], easting_northing: [location[1], location[0]]).first
        end
      elsif street.count == 0
        street = Street.create(name: address['street']['name']) # If there are no streets, create one
      end

      return street
    end

    def self.request_with_retries(url)
      tries = 1
      begin
        response = HTTParty.get(url)
        raise ArgumentException if response.code != 200
      rescue
        retry_secs = 5 * tries
        puts "#{url} responded with #{response.code}. Retrying in #{retry_secs} seconds."
        sleep(retry_secs)
        tries += 1
        retry
      end
      response.parsed_response
    end

    def self.derivations(address, parts)
      derivations = [
        {
          type: "Source",
          urls: [
            address['url']
          ],
          downloaded_at: DateTime.now,
          processing_script: "https://github.com/OpenAddressesUK/distiller/tree/#{current_sha}/lib/distil.rb"
        },
      ]

      parts.delete_if { |p| p.nil? }.each do |part|
        derivations << {
          type: "Source",
          urls: [
            part_url(part)
          ],
          downloaded_at: DateTime.now,
          processing_script: "https://github.com/OpenAddressesUK/distiller/tree/#{current_sha}/lib/distil.rb"
        }
      end

      derivations
    end

    def self.part_url(part)
      "http://alpha.openaddressesuk.org/#{part.class.to_s.downcase.pluralize}/#{part.token}"
    end

  end
end
