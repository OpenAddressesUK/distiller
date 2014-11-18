module Distiller
  class Indexes
    def self.create
      Address.create_indexes
      Street.create_indexes
      Postcode.create_indexes
      Locality.create_indexes
      Town.create_indexes
    end
  end
end
