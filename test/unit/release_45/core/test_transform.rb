#
# = test/unit/test_transform.rb - Unit test for Ensembl::Core
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <http://jandot.myopenid.com>
# License::     Ruby's
#
# $Id:
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'

require 'ensembl'

include Ensembl::Core
DBConnection.connect('bos_taurus')

# For all tests, the source (i.e. the seq_region that the feature is annotated
# on initially) remains forward.
#
# Same coordinate system: test names refer to direction of gene vs chromosome
class TransformOntoSameCoordinateSystem < Test::Unit::TestCase
  # |-------|========>-------------------------> chromosome
  #         ^        ^
  #         |        |
  # |-------|========>-------------------------> chromosome
  # This should return itself.
  def test_fw
    source_gene = Gene.find(2115)
    target_gene = source_gene.transform('chromosome')

    assert_equal('4', source_gene.seq_region.name)
    assert_equal(1454668, source_gene.seq_region_start)
    assert_equal(1483537, source_gene.seq_region_end)
    assert_equal(1, source_gene.seq_region_strand)
    assert_equal('4', target_gene.seq_region.name)
    assert_equal(1454668, target_gene.seq_region_start)
    assert_equal(1483537, target_gene.seq_region_end)
    assert_equal(1, target_gene.seq_region_strand)
  end

  # |-------<========|-------------------------> chromosome
  #         ^        ^
  #         |        |
  # |-------<========|-------------------------> chromosome
  # This should return itself.
  def test_rev
    source_gene = Gene.find(2408)
    target_gene = source_gene.transform('chromosome')

    assert_equal('4', source_gene.seq_region.name)
    assert_equal(8104409, source_gene.seq_region_start)
    assert_equal(8496477, source_gene.seq_region_end)
    assert_equal(-1, source_gene.seq_region_strand)
    assert_equal('4', target_gene.seq_region.name)
    assert_equal(8104409, target_gene.seq_region_start)
    assert_equal(8496477, target_gene.seq_region_end)
    assert_equal(-1, target_gene.seq_region_strand)
  end
end

# Test names refer to:
# (1) direction of gene vs chromosome
# (2) direction of component (scaffold) vs assembly (chromosome)
class TransformFromComponentToAssembly < Test::Unit::TestCase
  def test_fw_fw
    assert true
  end

  def test_fw_rev
    assert true
  end

  def test_rev_fw
    assert true
  end

  def test_rev_rev
    assert true
  end
end

# Test names refer to:
# (1) direction of gene vs chromosome
# (2) direction of component (scaffold) vs assembly (chromosome)
# We have to test for features that are covered by a scaffold, and those
# overlapping more than 1 scaffold.
class TransformFromAssemblyToComponent < Test::Unit::TestCase
  #       |-----------------> scaffold
  #           ^     ^
  #           |     |
  # |---------|=====>-----------------------------> chromosome
  def test_fw_fw_full_overlap
    source_gene = Gene.find(2995)
    target_gene = source_gene.transform('scaffold')

    assert_equal('4', source_gene.seq_region.name)
    assert_equal(10333321, source_gene.seq_region_start)
    assert_equal(10510842, source_gene.seq_region_end)
    assert_equal(1, source_gene.seq_region_strand)
    assert_equal('Chr4.003.12', target_gene.seq_region.name)
    assert_equal(43842, target_gene.seq_region_start)
    assert_equal(221363, target_gene.seq_region_end)
    assert_equal(1, target_gene.seq_region_strand)
  end

  #       |-----------------> scaffold
  #       |
  #       |
  # |---|===>-------------------------------> chromosome
  def test_fw_fw_partial_overlap
    source_feature = PredictionTranscript.find(52425)
    target_feature = source_feature.transform('scaffold')

    assert_equal('4', source_feature.seq_region.name)
    assert_equal(1443280, source_feature.seq_region_start)
    assert_equal(1482777, source_feature.seq_region_end)
    assert_equal(1, source_feature.seq_region_strand)
    assert_equal(nil, target_feature)
  end

  #       <-----------------| scaffold
  #            ^     ^
  #            |     |
  # |----------|=====>-----------------------------> chromosome
  def test_fw_rev_full_overlap
    source_gene = Gene.find(2708)
    target_gene = source_gene.transform('scaffold')

    assert_equal('4', source_gene.seq_region.name)
    assert_equal(8312492, source_gene.seq_region_start)
    assert_equal(8312812, source_gene.seq_region_end)
    assert_equal(1, source_gene.seq_region_strand)
    assert_equal('Chr4.003.10', target_gene.seq_region.name)
    assert_equal(1774466, target_gene.seq_region_start)
    assert_equal(1774786, target_gene.seq_region_end)
    assert_equal(-1, target_gene.seq_region_strand)
  end

  #       <-----------------| scaffold
  #                         |
  #                         |
  # |---------------------|===>------------------> chromosome
  def test_fw_rev_partial_overlap
    source_feature = PredictionTranscript.find(23305)
    target_feature = source_feature.transform('scaffold')

    assert_equal('4', source_feature.seq_region.name)
    assert_equal(10008188, source_feature.seq_region_start)
    assert_equal(10156104, source_feature.seq_region_end)
    assert_equal(1, source_feature.seq_region_strand)
    assert_equal(nil, target_feature)
  end

  #       |-----------------> scaffold
  #       |    ^     ^
  #       |    |     |
  # |---<===|--<=====|-----------------------------> chromosome
  def test_rev_fw_full_overlap
    source_gene = Gene.find(3124)
    target_gene = source_gene.transform('scaffold')

    assert_equal('4', source_gene.seq_region.name)
    assert_equal(10353230, source_gene.seq_region_start)
    assert_equal(10371155, source_gene.seq_region_end)
    assert_equal(-1, source_gene.seq_region_strand)
    assert_equal('Chr4.003.12', target_gene.seq_region.name)
    assert_equal(63751, target_gene.seq_region_start)
    assert_equal(81676, target_gene.seq_region_end)
    assert_equal(-1, target_gene.seq_region_strand)
  end

  #       |-----------------> scaffold
  #                         |
  #                         |
  # |---------------------<===|------------------> chromosome
  def test_rev_fw_partial_overlap
    source_feature = PredictionTranscript.find(24185)
    target_feature = source_feature.transform('scaffold')

    assert_equal('4', source_feature.seq_region.name)
    assert_equal(11389212, source_feature.seq_region_start)
    assert_equal(11471635, source_feature.seq_region_end)
    assert_equal(-1, source_feature.seq_region_strand)
    assert_equal(nil, target_feature)
  end

  #       <-----------------| scaffold
  #       |    ^     ^
  #       |    |     |
  # |---<===|--<=====|-----------------------------> chromosome
  def test_rev_rev_full_overlap
    source_gene = Gene.find(2408)
    target_gene = source_gene.transform('scaffold')

    assert_equal('4', source_gene.seq_region.name)
    assert_equal(8104409, source_gene.seq_region_start)
    assert_equal(8496477, source_gene.seq_region_end)
    assert_equal(-1, source_gene.seq_region_strand)
    assert_equal('Chr4.003.10', target_gene.seq_region.name)
    assert_equal(1590801, target_gene.seq_region_start)
    assert_equal(1982869, target_gene.seq_region_end)
    assert_equal(1, target_gene.seq_region_strand)
  end

  #       <-----------------| scaffold
  #       |
  #       |
  # |---<===|-----------------------------> chromosome
  def test_rev_rev_partial_overlap
    source_feature = Transcript.find(14723)
    target_feature = source_feature.transform('scaffold')

    assert_equal('4', source_feature.seq_region.name)
    assert_equal(55713316, source_feature.seq_region_start)
    assert_equal(55792273, source_feature.seq_region_end)
    assert_equal(-1, source_feature.seq_region_strand)
    assert_equal(nil, target_feature)
  end

end
