require 'rake'
require 'rake/rdoctask'

require 'spec/rake/spectask'
require 'rake/gempackagetask'

desc 'Default: run unit tests.'
task :default => :spec
 
desc 'Test the RAMF project using RSpec.'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'lib'
#  t.verbose = true
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_dir = "doc"
  rdoc.title    = 'Ramf'
  rdoc.options << '--line-numbers' << '--inline-source'
  rd.rdoc_files.include("README", "lib/**/*.rb")
end

namespace :spec do
  desc "Generate code coverage with rcov"
  task :rcov do
    rm_rf "coverage/coverage.data"
    rm_rf "coverage/"
    mkdir "coverage"
    rcov = %(rcov --text-summary -Ilib --html -o coverage spec/*_spec.rb spec/**/*_spec.rb)
    system rcov
    system "firefox coverage/index.html"
  end
end
