require 'spec_helper'

describe Distiller::Import do

  it "creates towns", :vcr do
    Distiller::Import.towns
    expect(Town.all.count).to eq(1501)
  end

end
