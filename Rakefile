namespace :gem do
 desc "Rebuild GEM and gemspec"
 task :rebuild do
  unless ENV.include?("version")
    raise "usage: rake gem:rebuild version= [number]" 
  end
  version = ENV['version'] 
  outfile = File.open('ruby-ensembl-api.gemspec','w')

  outfile.puts 'Gem::Specification.new do |s|'
  outfile.puts '  s.name = "ruby-ensembl-api"'
  outfile.puts '  s.version ='+"'#{version}'"
  outfile.puts ''
  outfile.puts '  s.authors = ["Jan Aerts", "Francesco Strozzi"]'
  outfile.puts '  s.email = ["jan.aerts@gmail.com","francesco.strozzi@gmail.com"]'
  outfile.puts '  s.homepage = "http://rubyforge.org/projects/bioruby-annex/"'
  outfile.puts '  s.summary = "API to Ensembl databases"'
  outfile.puts '  s.description = "ensembl-api provides a ruby API to the Ensembl databases (http://www.ensembl.org)"'
  outfile.puts ''
  outfile.puts '  s.has_rdoc = true'
  outfile.puts ''
  outfile.puts '  s.platform = Gem::Platform::RUBY'
  
  
  outfile.puts '  s.files = ["' + FileList.new("bin/*", "lib/**/*.rb", "samples/**/*", "test/**/*.rb", "doc/**/*.html").join("\",\"") + '"]'
  outfile.puts '  s.extra_rdoc_files = ["TUTORIAL.rdoc"]'
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
  system("gem build ruby-ensembl-api.gemspec")
 end
end 

namespace :test do
  
 desc "Run all tests for release 56"
 task :run => :base do
    Dir.glob("test/unit/release_56/**/*.rb").each do |name|
      ruby name
    end
 end
 
 desc "Run base tests (only connection and releases)"
 task :base do 
   Dir.glob("test/unit/*.rb").each do |name|
     ruby name
   end
   
 end
 
 desc "Run Core tests (only release 56)"
 task :core do
   Dir.glob("test/unit/release_53/core/*.rb").each do |name|
     ruby name
   end
 end
 desc "Run Variation tests (only release 56)"
 task :variation do
   Dir.glob("test/unit/release_53/variation/*.rb").each do |name|
     ruby name
   end
 end
 desc "Run Ensembl Genomes tests"
 task :genomes do
   Dir.glob("test/unit/ensembl_genomes/*.rb").each do |name|
     ruby name
   end
 end
 
 desc "Run tests for release 53"
 task :release53 do
   Dir.glob("test/unit/release_53/**/*.rb").each do |name|
     ruby name
   end
 end
 
 desc "Run tests for release 50"
 task :release50 do
   Dir.glob("test/unit/release_50/**/*.rb").each do |name|
     ruby name
   end
 end
 
 
end