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

namespace :distiller do

  namespace :import do

    task :towns do
      Distiller::Import.towns
    end

    task :postcodes do
      Distiller::Import.postcodes
    end

    task :localities do
      Distiller::Import.localities
    end

    task :streets do
      Distiller::Import.streets
    end

    task :all => [:towns, :postcodes, :localities, :streets]

  end

  namespace :distil do
    task :pages, :pages do |task, args|
      Distiller::Distil.perform(args[:pages])
    end

    task :all, :start_index, :step do |task, args|
      Distiller::Distil.perform(nil, args[:start_index].to_i, args[:step].to_i)
    end

    task :latest do
      desc "Distil latest"
      Distiller::Distil.from_date(ENV['DATE_TIME'] || nil)
    end
  end

end

task :default => :spec
