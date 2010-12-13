#
# = test/unit/release_50/variation/test_variation.tb - Unit test for Ensembl::Variation
#
# Copyright::   Copyright (C) 2008 Francesco Strozzi <francesco.strozzi@gmail.com>
#
# License::     Ruby's
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'lib/ensembl'

include Ensembl::Variation

DBConnection.connect('homo_sapiens',50)

class TestVariation < Test::Unit::TestCase
  
  def test_fetch_region
    vf = Variation.find_by_name('rs2076175').variation_features[0]
    slice = vf.fetch_region
    assert_equal(29816349,slice.start)
    assert_equal(29826349,slice.stop)
    assert_equal('6',slice.seq_region.name)
    slice = vf.fetch_region(30,30)
    assert_equal(29821319,slice.start)
    assert_equal(29821379,slice.stop)
    assert_equal('CTCCCAGGACTGCTTCTGCCCACTGTCCCCGGGGCCCTGCCCTGCCTTTCTGCCTGTCACA',slice.seq.upcase)
  end
  
  def test_flanking_seq
    vf = Variation.find_by_name('rs2076175').variation_features[0]
    up,down = vf.flanking_seq
    assert_equal(29820949,up.start)
    assert_equal(29821348,up.stop)
    assert_equal(29821350,down.start)
    assert_equal(29821749,down.stop)
    assert_equal('TCCTGATCTCACAAACCCTAATCTCCTGGAGGGAATGCAAGGCTGCCTGCCCCTACCCAGCAGTGACTTCTCCATTCCAGTCCAAGTGAGGAACTCGGACCAGGAAGGACCCCTCCCTGGCCCTCTTCCATCCCTCCCTGTGTGGGCTGAGCCCCGCTGAGCACCATTCCTCACCCCTACTCACAGCCAAATCCAGTGGGAAGAGACAGGTCCTGCTCTCTGCCCCCAACTCTCCTGGAAAAGGCCTCTCCCATTACTCTTGCCCACTGCCCACTCTCACCTCCTTTCTGGCCCTTGATATGAGCCAGGGTCCTCCTGAGCTCCTGCCCATTCTCTGTCAAGTCTTCAGTCTCTGTGTCCCAGGTCTCAGCTCCCAGGACTGCTTCTGCCCACTGTCCCC',
                  up.seq.upcase)
    assert_equal('GGGCCCTGCCCTGCCTTTCTGCCTGTCACAGAGCAGGAAGAGCTGACCATCCAGATGTCCCTCAGCGAGAAACCCTGACTGCACAGATCCATCCTGGGACAGCACCGTGAGGTTGTAACAAAGACTGTGGGGCTCTGGGGAAGAGGAAATCACAGATGAAACTTCTTCCTGGAAGTAACTTCACATCAATGTTTAACACACAGGTCTGCTGTCCCGACCTTCCTGAGGAGGCAGGAAATGCACACGGGCAAAGGGACAAGAATGAGGATTTCAGACGCAAGGAAAACTGGGAAGGTGGGAGGATAGAGGAGGGGACTGAGGAACAGAAGAAGGGGGAATGGGGATGGCAAACTTGTAGGCCAGGTGCCAGGGCAGGGCAGCCACAGGCCCCCTCAGGATA',
                down.seq.upcase)
                              
  end
  
  def test_slice_variation
    slice = Ensembl::Core::Slice.fetch_by_region('chromosome',1,50000,51000)
    variations = slice.get_variation_features
    assert_equal(9,variations.size)
    assert_equal('ENSSNP4691381',variations[0].variation_name)
    assert_equal('ENSSNP9996411',variations[1].variation_name)
    assert_equal('rs2691281',variations[2].variation_name)
    assert_equal('ENSSNP4068519',variations[3].variation_name)
    assert_equal('ENSSNP230814',variations[4].variation_name)
    assert_equal('ENSSNP4010737',variations[5].variation_name)
    assert_equal('rs2531295',variations[6].variation_name)
    assert_equal('ENSSNP5092147',variations[7].variation_name)
    assert_equal('ENSSNP5346602',variations[8].variation_name)
    
    genotyped = slice.get_genotyped_variation_features
    assert_equal(7,genotyped.size)
    assert_equal('ENSSNP4691381',genotyped[0].variation_name)
    assert_equal('genotyped',genotyped[0].flags)
    assert_equal('ENSSNP9996411',genotyped[1].variation_name)
    assert_equal('genotyped',genotyped[1].flags)
    assert_equal('ENSSNP4068519',genotyped[2].variation_name)
    assert_equal('genotyped',genotyped[2].flags)
    assert_equal('ENSSNP230814',genotyped[3].variation_name)
    assert_equal('genotyped',genotyped[3].flags)
    assert_equal('ENSSNP4010737',genotyped[4].variation_name)
    assert_equal('genotyped',genotyped[4].flags)
    assert_equal('ENSSNP5092147',genotyped[5].variation_name)
    assert_equal('genotyped',genotyped[5].flags)
    assert_equal('ENSSNP5346602',genotyped[6].variation_name)
    assert_equal('genotyped',genotyped[6].flags)
    
    v = variations[0].variation
    assert_equal(16366812,v.variation_id)
  end
  
  
  
end