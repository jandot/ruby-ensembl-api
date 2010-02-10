Gem::Specification.new do |s|
  s.name = "ruby-ensembl-api"
  s.version ='0.9.6'

  s.authors = ["Jan Aerts", "Francesco Strozzi"]
  s.email = ["jan.aerts@gmail.com","francesco.strozzi@gmail.com"]
  s.homepage = "http://github.com/jandot/ruby-ensembl-api"
  s.summary = "API to Ensembl databases"
  s.description = "ruby-ensembl-api provides a ruby API to the Ensembl databases (http://www.ensembl.org)"

  s.has_rdoc = true

  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["TUTORIAL.rdoc"]
  s.files = Dir['lib/**/*.rb'] + Dir['bin/ensembl']
  s.test_files = Dir['test/**/*']
  s.add_dependency("bio", [">=1"])
  s.add_dependency("activerecord")

  s.require_path = "lib"
  s.autorequire = "ensembl"

  s.bindir = "bin"
  s.executables = ["ensembl"]
  s.default_executable = "ensembl"
end
