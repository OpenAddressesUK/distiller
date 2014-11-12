require_relative './concerns/tokenable'

class Settlement < Tokenable

  field :name, type: String
  field :authority, type: String

end
