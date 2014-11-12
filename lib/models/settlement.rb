require_relative './concerns/tokenable'

class Settlement < Tokenable
  include Mongoid::Geospatial

  field :name, type: String
  field :authority, type: String

  geo_field :location
end
