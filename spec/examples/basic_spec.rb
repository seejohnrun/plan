require File.dirname(__FILE__) + '/../spec_helper'

describe Plan do

  it 'should have a version' do
    Plan::VERSION.should_not be_nil
  end

end
