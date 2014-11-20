ENV["MONGOID_ENVIRONMENT"] = "test"

require 'webmock/rspec'
require 'vcr'
require 'pry'
require 'database_cleaner'
require 'distiller'
require 'factory_girl'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.default_cassette_options = { :record => :once }
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.order = "random"
  config.include FactoryGirl::Syntax::Methods
  FactoryGirl.definition_file_paths = ["#{Gem.loaded_specs['mongoid_address_models'].full_gem_path}/lib/mongoid_address_models/factories"]
  FactoryGirl.find_definitions

  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
    Distiller::Indexes.create
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
