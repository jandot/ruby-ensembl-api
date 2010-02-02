#
# = test/unit/release_53/ensembl_genomes/test_gene.rb - Unit test for Ensembl::Core
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

class TestGene < Test::Unit::TestCase
  
  def setup
    DBConnection.ensemblgenomes_connect('pyrococcus_collection',3) 
  end
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_find_gene
    g = Gene.find_by_stable_id("EBPYRG00000005609")
    assert_equal("EBPYRG00000005609",g.stable_id)
    assert_equal(1195302,g.start)
    assert_equal(1196675,g.stop)
    assert_equal("Chromosome",g.seq_region.name)
    assert_equal("ATGAATAGGAGCTTGTACTTGATTTTTATAATTGTAGGATATACTTTGGGAATATGGACA",g.seq.slice(0,60).upcase)
  end
  
  def test_find_transcript
    g = Gene.find_by_stable_id("EBPYRG00000005609")
    t = g.transcripts
    assert_equal("EBPYRT00000005610",t[0].stable_id)
  end
  
  def test_find_exons
    g = Gene.find_by_stable_id("EBPYRG00000005609")
    t = g.transcripts
    e = t[0].exons
    assert_equal("EBPYRE00000005617",e[0].stable_id)
    assert_equal("ATGAATAGGAGCTTGTACTTGATTTTTATAATTGTAGGATATACTTTGGGAATATGGACA",e[0].seq.slice(0,60).upcase)  	
  end
  
end