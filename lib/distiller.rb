require 'mongoid'
require 'mongoid_token'

$:.unshift File.dirname(__FILE__)

Mongoid.load!(File.join(File.dirname(__FILE__), "..", "config", "mongoid.yml"), ENV["MONGOID_ENVIRONMENT"] || :development)

require 'httparty'
require 'nokogiri'
require 'zip'
require 'uk_postcode'

require 'models/town'
require 'models/postcode'
require 'models/settlement'

require 'import'

module Distiller
end
