require File.dirname(__FILE__) + '/lib/plan/version'

spec = Gem::Specification.new do |s|
  
  s.name = 'plan'  
  s.author = 'John Crepezzi'
  s.add_development_dependency('rspec')
  s.description = 'plan is a simple command-line todo-list manager'
  s.email = 'john.crepezzi@gmail.com'
  s.files = Dir['lib/**/*.rb', 'bin/plan']
  s.bindir = 'bin'
  s.executables = ['plan']
  s.homepage = 'http://github.com/seejohnrun/plan'
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.summary = 'simple command-line todo-list manager'
  s.test_files = Dir.glob('spec/*.rb')
  s.version = Plan::VERSION
  s.rubyforge_project = 'plan'

end
