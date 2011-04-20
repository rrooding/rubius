require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rubius"
  gem.homepage = "http://github.com/rahvin/rubius"
  gem.license = "MIT"
  gem.summary = %Q{A simple ruby RADIUS authentication gem}
  gem.description = %Q{Rubius provides a simple interface to RADIUS authentication}
  gem.email = "ralph@izerion.com"
  gem.authors = ["Ralph Rooding"]
  
  gem.add_development_dependency 'bundler', '~> 1.0.0'
  gem.add_development_dependency 'shoulda'
  gem.add_development_dependency 'mocha', '~> 0.9.12'
  gem.add_development_dependency 'jeweler', '~> 1.5.2'
  gem.add_development_dependency 'simplecov', '>= 0.4.0'
  gem.add_development_dependency 'autotest-standalone', '~> 4.5.5'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Rubius #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
