require 'rubygems'
require 'rake'

Gem::Specification.new do |s|
  s.name = "ruby-ensembl-api"
  s.version = "0.9.3"
  s.authors = ["Jan Aerts", "Francesco Strozzi"]
  s.email = "jan.aerts@gmail.com"
  s.homepage = "http://rubyforge.org/projects/bioruby-annex/"
  s.summary = "API to Ensembl databases"
  s.description = "ensembl-api provides a ruby API to the Ensembl databases (http://www.ensembl.org)"

  s.has_rdoc = true

  s.platform = Gem::Platform::RUBY
  s.files =  FileList['lib/**/*.rb', 'bin/*', '[A-Z]*'].to_a

  s.test_files = FileList['test/**/*'].to_a


  s.add_dependency("bio", [">=1"])
  s.add_dependency("activerecord")

  s.require_path = "lib"

  s.bindir = "bin"
  s.executables = ["ensembl"]
  s.default_executable = "ensembl"
end
