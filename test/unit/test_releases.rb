require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'

require 'ensembl'

include Ensembl::Core

# Let's see if we can 'find' things
class TestRelease45 < Test::Unit::TestCase
  def setup
    DBConnection.connect('homo_sapiens', 45)
    @slice = Slice.fetch_by_region('chromosome','1',1000,100000)
  end
  def test_gene_stable_id
    assert_equal(["ENSG00000146556", "ENSG00000177693", "ENSG00000197194", "ENSG00000197490", "ENSG00000205292"], @slice.genes.collect{|g| g.stable_id}.sort)
  end
end

class TestRelease37 < Test::Unit::TestCase
  def setup
    DBConnection.connect('homo_sapiens', 37)
    @slice = Slice.fetch_by_region('chromosome','1',1000,100000)
  end
  def test_gene_stable_id
    assert_equal(["ENSG00000146556", "ENSG00000177693", "ENSG00000197194", "ENSG00000197490"], @slice.genes.collect{|g| g.stable_id}.sort)
  end
end

class TestRelease50 < Test::Unit::TestCase
  def setup
    DBConnection.connect('homo_sapiens', 50)
    @slice = Slice.fetch_by_region('chromosome','1',1000,100000)
  end
  def test_gene_stable_id
    assert_equal(["ENSG00000146556", "ENSG00000177693", "ENSG00000197194", "ENSG00000197490", "ENSG00000205292", "ENSG00000219789", "ENSG00000221311"], @slice.genes.collect{|g| g.stable_id}.sort)
  end
end