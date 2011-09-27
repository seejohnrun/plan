require 'rspec/core/rake_task'
require File.dirname(__FILE__) + '/lib/plan/version'
 
task :build => :test do
  system "gem build plan.gemspec"
end

task :release => :build do
  # tag and push
  system "git tag v#{Plan::VERSION}"
  system "git push origin --tags"
  # push the gem
  system "gem push plan-#{Plan::VERSION}.gem"
end
 
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  fail_on_error = true # be explicit
end
 
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = true
  fail_on_error = true # be explicit
end
