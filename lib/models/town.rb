class Town
  include Mongoid::Document

  field :area, type: String
  field :name, type: String
end
