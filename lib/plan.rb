require File.dirname(__FILE__) + '/plan/version'
require File.dirname(__FILE__) + '/plan/advice'
require File.dirname(__FILE__) + '/plan/item'

module Plan
  autoload :CLI, File.dirname(__FILE__) + '/plan/cli' 
end
