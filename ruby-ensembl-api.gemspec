require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = 'ruby-ensembl-api'
  s.version = "0.9.1"

  s.authors = ["Jan Aerts"]
  s.email = "jan.aerts@gmail.com"
  s.homepage = "http://rubyforge.org/projects/bioruby-annex/"
  s.summary = "API to Ensembl databases"
  s.description = "ensembl-api provides a ruby API to the Ensembl databases (http://www.ensembl.org)"

  s.has_rdoc = true
  s.rdoc_options = ['--exclude .']
  
  s.platform = Gem::Platform::RUBY
  s.files = Dir.glob("{doc,lib,samples,test}/**/*")
  s.extra_rdoc_files = ["TUTORIAL"]
  
  s.test_files = Dir.glob("test/**/test_*.rb")


  s.add_dependency('bio', ['>=1'])
  s.add_dependency('activerecord')

  s.require_path = 'lib'
  s.autorequire = 'ensembl'
  
  s.bindir = "bin"
  s.executables = ["ensembl"]
  s.default_executable = "ensembl"
end

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end
