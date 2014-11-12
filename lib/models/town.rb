class Town
  include Mongoid::Document
  include Mongoid::Timestamps

  field :area, type: String
  field :name, type: String
end
