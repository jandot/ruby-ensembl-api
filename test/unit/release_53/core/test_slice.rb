#
# = test/unit/release_53/core/test_slice.rb - Unit test for Ensembl::Core
#
# Copyright::   Copyright (C) 2009
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

class TestSlice < Test::Unit::TestCase
  
  def setup
    DBConnection.connect('homo_sapiens', 53)
  end
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_forward
    seq1 = "AGAACCAACGAATTCGGAGATGAAGTCAGGTCTTCCAGTTCAGCCTGCGAGGAAGACAGGTGATCCGAATCCTAAGAATGCAAAAGATGGGCCGGGTGTGGTGGCTCATGCCTGTAATCCCAGCGCTTTGGGAGGCCGAGGCAGGCAGATCACCTGAGGTCGGGAGGTTGAGACCAGACTGACCAACAACGGAGAAACCC"
    s = Slice.fetch_by_region("chromosome","13",31786617,31786816,1)
    assert_equal(seq1,s.seq.upcase)
    assert_equal("13",s.seq_region.name)
    assert_equal(31786617,s.start)
    assert_equal(31786816,s.stop)
  end
  
  def test_reverse
    seq2 = "GGGTTTCTCCGTTGTTGGTCAGTCTGGTCTCAACCTCCCGACCTCAGGTGATCTGCCTGCCTCGGCCTCCCAAAGCGCTGGGATTACAGGCATGAGCCACCACACCCGGCCCATCTTTTGCATTCTTAGGATTCGGATCACCTGTCTTCCTCGCAGGCTGAACTGGAAGACCTGACTTCATCTCCGAATTCGTTGGTTCT"
    s_rev = Slice.fetch_by_region("chromosome","13",31786617,31786816,-1)
    assert_equal(seq2,s_rev.seq.upcase)
    assert_equal("13",s_rev.seq_region.name)
    assert_equal(31786617,s_rev.start)
    assert_equal(31786816,s_rev.stop)
  end

end