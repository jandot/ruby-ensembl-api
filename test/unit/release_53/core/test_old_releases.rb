#
# = test/unit/release_53/core/test_old_releases.rb - Unit test for Ensembl::Core
#
# Copyright::   Copyright (C) 2009 Francesco Strozzi <francesco.strozzi@gmail.com>
#
# License::     Ruby's
#
# $Id:

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'lib/ensembl'

include Ensembl::Core

class TestOldReleases < Test::Unit::TestCase
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_release_45
    DBConnection.connect('mus_musculus',45)
    
    slice = Slice.fetch_by_region('chromosome',"11",101037431,101037530)
    assert_equal("ACTCTATCCAACTGAAACTGGAGATTAGTAACAGGGAAAAACAAACTCAACTGACAGCTGCTCCCAGTACAGTTCTTATGGTACAGGGAGCGTGGGAGTG",slice.seq.upcase)
    
    gene = Gene.find_by_stable_id("ENSMUSG00000017167")
    assert_equal(100992131,gene.start)
    assert_equal(101006814,gene.stop)
    assert_equal("11",gene.seq_region.name)
    assert_equal(2,gene.transcripts.size)
  end
  
  def test_release_47
    DBConnection.connect('mus_musculus',47)
    
    slice = Slice.fetch_by_region('chromosome',"5",123840876,123912619)
    genes = slice.genes
    assert_equal("ENSMUSG00000038342",genes[0].stable_id)
    slice = Slice.fetch_by_region('chromosome',"5",123840876,123840975)
    assert_equal("TCTCAGTTCAGGTTCTATGGGGGGGAGGGGAGGGAATGAAAAGGATGTTAACAATCACCATCACCAGGGGGGACCAATTTGAAGATCTGATCGCCGGTGT",slice.seq.upcase)
    
    gene = Gene.find_by_stable_id("ENSMUSG00000017167")
    assert_equal(101037431, gene.start)
    assert_equal(101052034, gene.stop)
    assert_equal(1,gene.transcripts.size)
    assert_equal("ENSMUST00000103109",gene.transcripts[0].stable_id)
  end
  
  def test_release_49
    DBConnection.connect('mus_musculus',49)
    
    slice = Slice.fetch_by_region('chromosome',"19",52571924,52572023)
    assert_equal("AAGGTTGTATTCTAGTTTGCTCTCTGTTATTGTGACAAAGACAGGACCAAAGAAACTTGAGTAGGAAATGGTTGATAAAATCTTACAAGTTAGAAGGCAG",slice.seq.upcase)
    
    gene = Gene.find_by_stable_id("ENSMUSG00000017167")
    assert_equal(101037431, gene.start)
    assert_equal(101052034, gene.stop)
    assert_equal(1,gene.transcripts.size)
    assert_equal("ENSMUST00000103109",gene.transcripts[0].stable_id)
  end
  
end  
  