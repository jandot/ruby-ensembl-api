Gem::Specification.new do |s|
  s.name = "ruby-ensembl-api"
  s.version ='0.9.4'
  s.authors = ["Jan Aerts", "Francesco Strozzi"]
  s.email = ["jan.aerts@gmail.com","francesco.strozzi@gmail.com"]
  s.homepage = "http://rubyforge.org/projects/bioruby-annex/"
  s.summary = "API to Ensembl databases"
  s.description = "ensembl-api provides a ruby API to the Ensembl databases (http://www.ensembl.org)"

  s.has_rdoc = true

  s.platform = Gem::Platform::RUBY
  s.files = ["bin/ensembl","lib/ensembl/core/activerecord.rb","lib/ensembl/core/collection.rb","lib/ensembl/core/project.rb","lib/ensembl/core/slice.rb","lib/ensembl/core/transcript.rb","lib/ensembl/core/transform.rb","lib/ensembl/db_connection.rb","lib/ensembl/variation/activerecord.rb","lib/ensembl/variation/variation.rb","lib/ensembl.rb","samples/ensembl_genomes_example.rb","samples/examples_perl_tutorial.rb","samples/small_example_ruby_api.rb","samples/variation_example.rb","test/unit/release_50/core/test_project.rb","test/unit/release_50/core/test_project_human.rb","test/unit/release_50/core/test_relationships.rb","test/unit/release_50/core/test_sequence.rb","test/unit/release_50/core/test_slice.rb","test/unit/release_50/core/test_transcript.rb","test/unit/release_50/core/test_transform.rb","test/unit/release_50/variation/test_activerecord.rb","test/unit/release_50/variation/test_variation.rb","test/unit/release_53/core/test_gene.rb","test/unit/release_53/core/test_project.rb","test/unit/release_53/core/test_project_human.rb","test/unit/release_53/core/test_slice.rb","test/unit/release_53/core/test_transform.rb","test/unit/release_53/ensembl_genomes/test_collection.rb","test/unit/release_53/ensembl_genomes/test_gene.rb","test/unit/release_53/ensembl_genomes/test_slice.rb","test/unit/release_53/ensembl_genomes/test_variation.rb","test/unit/release_53/variation/test_activerecord.rb","test/unit/release_53/variation/test_variation.rb","test/unit/test_connection.rb","test/unit/test_releases.rb"]
  s.extra_rdoc_files = ["TUTORIAL"]

  s.test_files = ["test/unit/release_50/core/test_project.rb","test/unit/release_50/core/test_project_human.rb","test/unit/release_50/core/test_relationships.rb","test/unit/release_50/core/test_sequence.rb","test/unit/release_50/core/test_slice.rb","test/unit/release_50/core/test_transcript.rb","test/unit/release_50/core/test_transform.rb","test/unit/release_50/variation/test_activerecord.rb","test/unit/release_50/variation/test_variation.rb","test/unit/release_53/core/test_gene.rb","test/unit/release_53/core/test_project.rb","test/unit/release_53/core/test_project_human.rb","test/unit/release_53/core/test_slice.rb","test/unit/release_53/core/test_transform.rb","test/unit/release_53/ensembl_genomes/test_collection.rb","test/unit/release_53/ensembl_genomes/test_gene.rb","test/unit/release_53/ensembl_genomes/test_slice.rb","test/unit/release_53/ensembl_genomes/test_variation.rb","test/unit/release_53/variation/test_activerecord.rb","test/unit/release_53/variation/test_variation.rb","test/unit/test_connection.rb","test/unit/test_releases.rb"]


  s.add_dependency("bio", [">=1"])
  s.add_dependency("activerecord")

  s.require_path = "lib"
  s.autorequire = "ensembl"

  s.bindir = "bin"
  s.executables = ["ensembl"]
  s.default_executable = "ensembl"
end
