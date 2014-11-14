module Distiller
  class Indexes
    def self.create
      Street.create_indexes
      Postcode.create_indexes
      Locality.create_indexes
    end
  end
end
