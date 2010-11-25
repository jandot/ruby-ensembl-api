#
# = test/unit/release_56/variation/test_variation.tb - Unit test for Ensembl::Variation
#
# Copyright::   Copyright (C) 2009
#               Francesco Strozzi <francesco.strozzi@gmail.com>
# License::     Ruby's
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'lib/ensembl'

include Ensembl::Variation

class TestVariation < Test::Unit::TestCase
  
  def setup
    DBConnection.connect('homo_sapiens',60)
  end
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_fetch_region
    vf = Variation.find_by_name('rs2076175').variation_features[0]
    slice = vf.fetch_region
    assert_equal(29708370,slice.start)
    assert_equal(29718370,slice.stop)
    assert_equal('6',slice.seq_region.name)
    slice = vf.fetch_region(30,30)
    assert_equal(29713340,slice.start)
    assert_equal(29713400,slice.stop)
    assert_equal('CTCCCAGGACTGCTTCTGCCCACTGTCCCCGGGGCCCTGCCCTGCCTTTCTGCCTGTCACA',slice.seq.upcase)
  end
  
  def test_flanking_seq
    vf = Variation.find_by_name('rs2076175').variation_features[0]
    up,down = vf.flanking_seq
    assert_equal(29712970,up.start)
    assert_equal(29713369,up.stop)
    assert_equal(29713371,down.start)
    assert_equal(29713770,down.stop)
    assert_equal('TCCTGATCTCACAAACCCTAATCTCCTGGAGGGAATGCAAGGCTGCCTGCCCCTACCCAGCAGTGACTTCTCCATTCCAGTCCAAGTGAGGAACTCGGACCAGGAAGGACCCCTCCCTGGCCCTCTTCCATCCCTCCCTGTGTGGGCTGAGCCCCGCTGAGCACCATTCCTCACCCCTACTCACAGCCAAATCCAGTGGGAAGAGACAGGTCCTGCTCTCTGCCCCCAACTCTCCTGGAAAAGGCCTCTCCCATTACTCTTGCCCACTGCCCACTCTCACCTCCTTTCTGGCCCTTGATATGAGCCAGGGTCCTCCTGAGCTCCTGCCCATTCTCTGTCAAGTCTTCAGTCTCTGTGTCCCAGGTCTCAGCTCCCAGGACTGCTTCTGCCCACTGTCCCC',
                  up.seq.upcase)
    assert_equal('GGGCCCTGCCCTGCCTTTCTGCCTGTCACAGAGCAGGAAGAGCTGACCATCCAGATGTCCCTCAGCGAGAAACCCTGACTGCACAGATCCATCCTGGGACAGCACCGTGAGGTTGTAACAAAGACTGTGGGGCTCTGGGGAAGAGGAAATCACAGATGAAACTTCTTCCTGGAAGTAACTTCACATCAATGTTTAACACACAGGTCTGCTGTCCCGACCTTCCTGAGGAGGCAGGAAATGCACACGGGCAAAGGGACAAGAATGAGGATTTCAGACGCAAGGAAAACTGGGAAGGTGGGAGGATAGAGGAGGGGACTGAGGAACAGAAGAAGGGGGAATGGGGATGGCAAACTTGTAGGCCAGGTGCCAGGGCAGGGCAGCCACAGGCCCCCTCAGGATA',
                down.seq.upcase)
                              
  end
  
  def test_slice_variation
    slice = Ensembl::Core::Slice.fetch_by_region('chromosome',1,100834,101331)
    variations = slice.get_variation_features
    assert_equal(1,variations.size)
    
    assert_equal('rs78180088',variations[0].variation_name)


  end
  
  
  
end