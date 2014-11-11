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

    end

  end
end
