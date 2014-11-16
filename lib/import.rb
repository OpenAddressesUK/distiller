module Distiller
  class Import

    extend Distiller::Helpers

    def self.localities
      ipn = HTTParty.get("https://github.com/OpenAddressesUK/IPN_2012/blob/master/IPN2012.csv?raw=true").parsed_response

      CSV.parse(ipn, headers: true) do |row|
        ll = en_to_ll(row['GRIDGB1E'], row['GRIDGB1N'])
        Locality.create(
                          name: row['PLACE12NM'].chomp(")"),
                          authority: get_authority(row),
                          location: [ll[:lat], ll[:lng]]
                         )
      end

    end

    def self.get_authority(row)
      authority = [
        row['NMD12CD'],
        row['UA12CD'],
        row['MD12CD'],
        row['LONB12CD']
      ].reject! { |a| a.blank? }

      return authority.first if authority.count == 1
    end

    def self.towns
      page = Nokogiri.parse HTTParty.get("https://en.wikipedia.org/wiki/List_of_post_towns_in_the_United_Kingdom").body
      rows = page.css("table.toccolours tr")
      rows.shift # Remove the header row

      rows.each do |row|
        area = row.css("td").first.inner_text
        towns = row.css("td").last.css("a[href^='/wiki']").each do |town|
          Town.create(area: area, name: town.inner_text)
        end
      end
    end

    def self.postcodes
      zip = Tempfile.new("postcodes.zip")
      zip.binmode
      zip.write HTTParty.get("https://geoportal.statistics.gov.uk/Docs/PostCodes/ONSPD_AUG_2014_csv.zip").parsed_response
      zip.close

      Zip::File.open(zip.path)do |zip_file|
        entry = zip_file.glob('ONSPD_AUG_2014_csv/Data/*.csv').first
        CSV.parse(entry.get_input_stream.read, headers: true) do |row|
          pc = UKPostcode.new(row['pcd'])
          ll = en_to_ll(row['oseast1m'], row['osnrth1m'])
          Postcode.create(
                          name: pc.norm,
                          area: pc.area,
                          outcode: pc.outcode,
                          incode: pc.incode,
                          easting: row['oseast1m'],
                          northing: row['osnrth1m'],
                          introduced: parse_date(row['dointr']),
                          terminated: parse_date(row['doterm']),
                          authority: row['oslaua'],
                          location: [ll[:lat], ll[:lng]]
                         )
        end
      end

    end

    def self.streets
      ("a".."d").each do |letter|
        locator = HTTParty.get("https://github.com/OpenAddressesUK/OS_Locator/blob/gh-pages/OS_Locator2014_2_OPEN_xa#{letter}.txt?raw=true").parsed_response

        CSV.parse(locator, col_sep: ":") do |row|
          ll = en_to_ll(row[2], row[3])
          Street.create(
            name: row[0],
            settlement: row[8],
            locality: row[9],
            authority:row[11],
            location: [ll[:lat], ll[:lng]]
          )
        end
      end
    end

    def self.parse_date(date, format = "%Y%m")
      if !date.blank?
        DateTime.strptime(date, "%Y%m")
      end
    end

  end
end
