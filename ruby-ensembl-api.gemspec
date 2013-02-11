Gem::Specification.new do |s|
  s.name = "ruby-ensembl-api"
  s.version ='1.0.1'

  s.authors = ["Jan Aerts", "Francesco Strozzi"]
  s.email = ["jan.aerts@gmail.com","francesco.strozzi@gmail.com"]
  s.homepage = "http://github.com/jandot/ruby-ensembl-api"
  s.summary = "API to Ensembl databases"
  s.description = "ruby-ensembl-api provides a ruby API to the Ensembl databases (http://www.ensembl.org)"

  s.has_rdoc = "yard"

  s.platform = Gem::Platform::RUBY
  s.files = ["bin/ensembl","bin/variation_effect_predictor","lib/ensembl/core/activerecord.rb","lib/ensembl/core/collection.rb","lib/ensembl/core/project.rb","lib/ensembl/core/slice.rb","lib/ensembl/core/transcript.rb","lib/ensembl/core/transform.rb","lib/ensembl/db_connection.rb","lib/ensembl/variation/activerecord.rb","lib/ensembl/variation/variation.rb","lib/ensembl.rb","samples/ensembl_genomes_example.rb","samples/examples_perl_tutorial.rb","samples/small_example_ruby_api.rb","samples/variation_example.rb","test/unit/release_60/core/test_gene.rb","test/unit/release_60/core/test_slice.rb","test/unit/release_60/core/test_transform.rb","test/unit/release_60/core/test_project_human.rb","test/unit/release_60/core/test_transcript.rb","test/unit/release_60/variation/test_activerecord.rb","test/unit/release_60/variation/test_consequence.rb","test/unit/release_60/variation/test_variation.rb","test/unit/test_connection.rb","test/unit/test_releases.rb"]
  s.extra_rdoc_files = ["TUTORIAL.rdoc"]

  s.test_files = ["test/unit/release_60/core/test_gene.rb","test/unit/release_60/core/test_slice.rb","test/unit/release_60/core/test_transform.rb","test/unit/release_60/core/test_project_human.rb","test/unit/release_60/core/test_transcript.rb","test/unit/release_60/variation/test_activerecord.rb","test/unit/release_60/variation/test_consequence.rb","test/unit/release_60/variation/test_variation.rb","test/unit/test_connection.rb","test/unit/test_releases.rb"]

  s.add_dependency("bio", [">=1"])
  s.add_dependency("activerecord", [">=3.2"])
  s.add_dependency("activerecord-mysql-adapter")
  s.add_dependency("mysql",["=2.8.1"])
  s.require_path = "lib"

  s.bindir = "bin"
  s.executables = ["ensembl"]
  s.default_executable = "ensembl"
end
