desc "Rebuild gemspec"
task :rebuild_gemspec do
  outfile = File.open('ruby-ensembl-api.gemspec','w')

  outfile.puts 'Gem::Specification.new do |s|'
  outfile.puts '  s.name = "ruby-ensembl-api"'
  outfile.puts '  s.version = "0.9.1"'
  outfile.puts ''
  outfile.puts '  s.authors = ["Jan Aerts"]'
  outfile.puts '  s.email = "jan.aerts@gmail.com"'
  outfile.puts '  s.homepage = "http://rubyforge.org/projects/bioruby-annex/"'
  outfile.puts '  s.summary = "API to Ensembl databases"'
  outfile.puts '  s.description = "ensembl-api provides a ruby API to the Ensembl databases (http://www.ensembl.org)"'
  outfile.puts ''
  outfile.puts '  s.has_rdoc = true'
  outfile.puts '  s.rdoc_options = ["--exclude ."]'
  outfile.puts ''
  outfile.puts '  s.platform = Gem::Platform::RUBY'
  
  
  outfile.puts '  s.files = ["' + FileList.new("bin/*", "doc/**/*", "lib/**/*.rb", "samples/**/*", "test/**/*.rb").join("\",\"") + '"]'
  outfile.puts '  s.extra_rdoc_files = ["TUTORIAL"]'
  outfile.puts ''
  outfile.puts '  s.test_files = ["' + FileList.new("test/**/test_*.rb").join("\",\"") + '"]'
  outfile.puts ''
  outfile.puts ''
  outfile.puts '  s.add_dependency("bio", [">=1"])'
  outfile.puts '  s.add_dependency("activerecord")'
  outfile.puts ''
  outfile.puts '  s.require_path = "lib"'
  outfile.puts '  s.autorequire = "ensembl"'
  outfile.puts ''
  outfile.puts '  s.bindir = "bin"'
  outfile.puts '  s.executables = ["ensembl"]'
  outfile.puts '  s.default_executable = "ensembl"'
  outfile.puts 'end'

  outfile.close
end