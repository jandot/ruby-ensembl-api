require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = 'ruby-ensembl-api'
  s.version = "0.9"

  s.author = "Jan Aerts"
  s.email = "jan.aerts@gmail.com"
  s.homepage = "http://rubyforge.org/projects/bioruby-annex/"
  s.summary = "API to Ensembl databases"
  s.description = "ensembl-api provides a ruby API to the Ensembl databases (http://www.ensembl.org)"

  s.platform = Gem::Platform::RUBY
  s.files = Dir.glob("{doc,lib,samples,test}/**/*")
  s.files.concat ["TUTORIAL"]

  s.rdoc_options << '--exclude' << '.'
  s.has_rdoc = true

  s.add_dependency('bio', '>=1')
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
