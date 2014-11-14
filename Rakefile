$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rspec/core/rake_task'
require 'distiller'

RSpec::Core::RakeTask.new(:spec)

namespace :db do
  task :create_indexes do
    Mongoid.models.each do |model|
      Distiller::Indexes.create
    end
  end
end

task :default => :spec
