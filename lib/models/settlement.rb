class Settlement
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :authority, type: String

end
