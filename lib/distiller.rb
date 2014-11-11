require 'mongoid'
$:.unshift File.dirname(__FILE__)

Mongoid.load!(File.join(File.dirname(__FILE__), "..", "config", "mongoid.yml"), ENV["MONGOID_ENVIRONMENT"] || :development)

require 'httparty'
require 'nokogiri'

require 'models/town'

require 'import'

module Distiller
end
