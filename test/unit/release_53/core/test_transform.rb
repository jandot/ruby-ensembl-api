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
    DBConnection.connect('homo_sapiens', 53)
  end
  
  def teardown
    DBConnection.remove_connection
  end

  def test_rev
    source_gene = Gene.find(102634)
    target_gene = source_gene.transform('chromosome')

    assert_equal('18', source_gene.seq_region.name)
    assert_equal(17659657, source_gene.seq_region_start)
    assert_equal(17659744, source_gene.seq_region_end)
    assert_equal(-1, source_gene.seq_region_strand)
    assert_equal('18', target_gene.seq_region.name)
    assert_equal(17659657, target_gene.seq_region_start)
    assert_equal(17659744, target_gene.seq_region_end)
    assert_equal(-1, target_gene.seq_region_strand)
  end

  def test_fw
    source_gene = Gene.find(103817)
    target_gene = source_gene.transform('chromosome')
    assert_equal('11', source_gene.seq_region.name)
    assert_equal(66886461, source_gene.seq_region_start)
    assert_equal(66886755, source_gene.seq_region_end)
    assert_equal(1, source_gene.seq_region_strand)
    assert_equal('11', target_gene.seq_region.name)
    assert_equal(66886461, target_gene.seq_region_start)
    assert_equal(66886755, target_gene.seq_region_end)
    assert_equal(1, target_gene.seq_region_strand)
  end

end