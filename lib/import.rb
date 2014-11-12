module Distiller
  class Import

    def self.settlements
      ipn = HTTParty.get("https://github.com/OpenAddressesUK/IPN_2012/blob/master/IPN2012.csv?raw=true").parsed_response

      CSV.parse(ipn, headers: true) do |row|
        Settlement.create(
                          name: row['PLACE12NM'].chomp(")"),
                          authority: get_authority(row),
                          location: [row['GRIDGB1E'], row['GRIDGB1N']]
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
          Postcode.create(
                          postcode: pc.norm,
                          area: pc.area,
                          outcode: pc.outcode,
                          incode: pc.incode,
                          easting: row['oseast1m'],
                          northing: row['osnrth1m'],
                          introduced: parse_date(row['dointr']),
                          terminated: parse_date(row['doterm']),
                          authority: row['oslaua'],
                          location: [row['oseast1m'], row['osnrth1m']]
                         )
        end
      end

    end

    def self.parse_date(date, format = "%Y%m")
      if !date.nil?
        DateTime.strptime(date, "%Y%m")
      end
    end

  end
end
