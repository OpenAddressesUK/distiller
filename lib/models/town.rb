require_relative './concerns/tokenable'

class Town < Tokenable
  field :area, type: String
  field :name, type: String
end
