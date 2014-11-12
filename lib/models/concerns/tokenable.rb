class Tokenable
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  token :contains => :alphanumeric, :length => 6
end
