require 'bundler'
Bundler.require(:default)

require 'mongoid_address_models/require_all'

Mongoid.load!(File.join(File.dirname(__FILE__), "..", "config", "mongoid.yml"), ENV["MONGOID_ENVIRONMENT"] || :development)

require 'httparty'
require 'nokogiri'
require 'zip'
require 'uk_postcode'
require 'dotenv'

Dotenv.load

require 'helpers'
require 'import'
require 'distil'
require 'indexes'

WebMock.allow_net_connect! unless ENV["MONGOID_ENVIRONMENT"] == "test"

module Distiller
end
