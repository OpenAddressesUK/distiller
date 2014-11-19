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
  
  task :distil, :pages do |task, args|
    Distiller::Distil.perform(args[:pages])
  end
  
end

task :default => :spec
