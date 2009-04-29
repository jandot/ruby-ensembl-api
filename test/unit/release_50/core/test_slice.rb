#
# = test/unit/test_project.rb - Unit test for Ensembl::Core
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
DBConnection.connect('bos_taurus', 50)

class GetFeatures < Test::Unit::TestCase
  # Chr4.003.122 has no simple features in itself, but the corresponding region
  # covered by the chromosome has 37. In addition, contigs within the scaffold
  # have 85. Total should therefore be 122.
  def test_simple_features
    contig = SeqRegion.find_by_name('AAFC03055312')
    assert_equal(19, contig.simple_features.length)
    assert_equal(19, contig.slice.simple_features.length)
    slice = Slice.fetch_by_region('contig','AAFC03055312')
    assert_equal(19, slice.simple_features.length)
  end
end

class SliceMethodMissing < Test::Unit::TestCase
  def setup
    @slice = Slice.fetch_by_region('chromosome','4',10000,10000000)
  end
  
  # There is not NotExistingTable class
  def test_non_existing_tables
    assert_raise(NoMethodError) { @slice.not_existing_tables }
  end
  
  # A slice can get its exons
  def test_exons
    assert_equal(291, @slice.exons.length)
    assert_equal(Exon, @slice.exons[0].class)
  end
  
  # A slice can _not_ get its markers; it has marker_features instead.
  def test_markers
    assert_raise(NoMethodError) { @slice.markers }
  end
  
  def test_transcripts
    assert_equal(36, @slice.transcripts.length)
  end
end

class GetOverlappingObjects < Test::Unit::TestCase
  def setup
    @small_slice = Slice.fetch_by_region('chromosome','Un.004.10515',850,900)
    @genes_inclusive = @small_slice.genes(true)
    @genes_exclusive = @small_slice.genes
    
    @large_slice = Slice.fetch_by_region('contig','AAFC03055312',1,18210)
    @repeats_inclusive = @large_slice.repeat_features(true).select{|r| r.analysis_id == 6}
  end
  
  def test_get_gene
    assert_equal(1, @genes_inclusive.length)
    assert_equal('ENSBTAG00000039669', @genes_inclusive[0].stable_id)
    assert_equal(0, @genes_exclusive.length)
  end
  
  def test_get_repeat_features
    assert_equal(2, @repeats_inclusive.length)
  end
end

class ExcisingSlice < Test::Unit::TestCase
  def setup
    @original_slice = Slice.fetch_by_region('chromosome','1',1,1000)
  end
  
  def test_excise_one_range
    output = @original_slice.excise([20..50])
    assert_equal(2, output.length)
    assert_equal('chromosome:Btau_4.0:1:1:19:1', output[0].to_s)
    assert_equal('chromosome:Btau_4.0:1:51:1000:1', output[1].to_s)
  end
  
  def test_excise_two_nonoverlapping_ranges
    output = @original_slice.excise([20..50,100..200])
    assert_equal(3, output.length)
    assert_equal('chromosome:Btau_4.0:1:1:19:1', output[0].to_s)
    assert_equal('chromosome:Btau_4.0:1:51:99:1', output[1].to_s)
    assert_equal('chromosome:Btau_4.0:1:201:1000:1', output[2].to_s)
  end

  def test_excise_two_overlapping_ranges
    output = @original_slice.excise([20..150,100..200])
    assert_equal(2, output.length)
    assert_equal('chromosome:Btau_4.0:1:1:19:1', output[0].to_s)
    assert_equal('chromosome:Btau_4.0:1:201:1000:1', output[1].to_s)
  end

  def test_excise_two_adjacent_ranges
    output = @original_slice.excise([20..99,100..200])
    assert_equal(2, output.length)
    assert_equal('chromosome:Btau_4.0:1:1:19:1', output[0].to_s)
    assert_equal('chromosome:Btau_4.0:1:201:1000:1', output[1].to_s)
  end
  
  def test_excise_internal_ranges
    output = @original_slice.excise([20..300,100..200])
    assert_equal(2, output.length)
    assert_equal('chromosome:Btau_4.0:1:1:19:1', output[0].to_s)
    assert_equal('chromosome:Btau_4.0:1:201:1000:1', output[1].to_s)
  end

  
end