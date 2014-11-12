module Distiller
  class Import

    def self.settlements


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
                          northing: row['osnrth1m']
                         )
        end
      end

    end

  end
end
