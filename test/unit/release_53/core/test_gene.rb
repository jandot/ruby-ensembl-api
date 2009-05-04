#
# = test/unit/release_53/core/test_gene.rb - Unit test for Ensembl::Core
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

class TestGene < Test::Unit::TestCase
  
  def setup
    DBConnection.connect('homo_sapiens', 53)
  end
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_gene
    g = Gene.find_by_stable_id("ENSG00000006451")
    assert_equal("ENSG00000006451",g.stable_id)
    assert_equal("7",g.seq_region.name)
    assert_equal(39629687,g.start)
    assert_equal(39714240,g.stop)
    assert_equal(1,g.strand)
    assert_equal(84554,g.seq.length)
    assert_equal("Ras-related protein Ral-A Precursor  [Source:UniProtKB/Swiss-Prot;Acc:P11233]",g.description)
    assert_equal("RALA",g.name)
  end
  
  def test_transcript
    g = Gene.find_by_stable_id("ENSG00000006451")
    t = g.transcripts
    assert_equal(1,t.size)
    assert_equal("ENST00000005257",t[0].stable_id)
    t = t[0]
    assert_equal(2792,t.seq.length)
  end
  
  def test_exons
    t = Transcript.find_by_stable_id("ENST00000005257")
    e = t.exons
    assert_equal(5,e.size)
    assert_equal("ENSE00001324495",e[0].stable_id)
    seq1 = "AAGTGATCTGTGGCGGCTGCTGCAGAGCCGCCAGGAGGAGGGTGGATCTCCCCAGAGCAAAGCGTCGGAGTCCTCCTCCTCCTTCTCCTCCTCCTCCTCCTCCTCCTCCAGCCGCCCAGGCTCCCCCGCCACCCGTCAGACTCCTCCTTCGACCGCTCCCGGCGCGGGGCCTTCCAGGCGACAAGGACCGAGTACCCTCCGGCCGGAGCCACGCAGCCGCGGCTTCCGGAGCCCTCGGGGCGGCGGACTGGCTCGCGGTGCAG"
    assert_equal(seq1,e[0].seq.upcase)
    assert_equal(39629687,e[0].start)
    assert_equal(39629949,e[0].stop)
    assert_equal("ENSE00000832451",e[1].stable_id)
    seq2 = "ATTCTTCTTAATCCTTTGGTGAAAACTGAGACACAAAATGGCTGCAAATAAGCCCAAGGGTCAGAATTCTTTGGCTTTACACAAAGTCATCATGGTGGGCAGTGGTGGCGTGGGCAAGTCAGCTCTGACTCTACAGTTCATGTACGATGAG"
    assert_equal(seq2,e[1].seq.upcase)
    assert_equal(39692755,e[1].start)
    assert_equal(39692905,e[1].stop)
  end

end