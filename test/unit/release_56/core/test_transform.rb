#
# = test/unit/release_53/core/test_transform.rb - Unit test for Ensembl::Core
#
# Copyright::   Copyright (C) 2009
#               Jan Aerts <http://jandot.myopenid.com>
#               Francesco Strozzi <francesco.strozzi@gmail.com>
# License::     Ruby's
#
# $Id:

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'

require 'lib/ensembl'

include Ensembl::Core


# For all tests, the source (i.e. the seq_region that the feature is annotated
# on initially) remains forward.
#
# Same coordinate system: test names refer to direction of gene vs chromosome
class TransformOntoSameCoordinateSystem < Test::Unit::TestCase

  def setup
    DBConnection.connect('homo_sapiens', 56)
  end
  
  def teardown
    DBConnection.remove_connection
  end

  def test_rev
    source_gene = Gene.find_by_stable_id("ENSG00000165322")
    target_gene = source_gene.transform('chromosome')

    assert_equal('10', source_gene.seq_region.name)
    assert_equal(32094365, source_gene.seq_region_start)
    assert_equal(32217770, source_gene.seq_region_end)
    assert_equal(-1, source_gene.seq_region_strand)
    assert_equal('10', target_gene.seq_region.name)
    assert_equal(32094365, target_gene.seq_region_start)
    assert_equal(32217770, target_gene.seq_region_end)
    assert_equal(-1, target_gene.seq_region_strand)
  end

  def test_fw
    source_gene = Gene.find_by_stable_id("ENSG00000133401")
    target_gene = source_gene.transform('chromosome')
    assert_equal('5', source_gene.seq_region.name)
    assert_equal(31639517, source_gene.seq_region_start)
    assert_equal(32111037, source_gene.seq_region_end)
    assert_equal(1, source_gene.seq_region_strand)
    assert_equal('5', target_gene.seq_region.name)
    assert_equal(31639517, target_gene.seq_region_start)
    assert_equal(32111037, target_gene.seq_region_end)
    assert_equal(1, target_gene.seq_region_strand)
  end

end