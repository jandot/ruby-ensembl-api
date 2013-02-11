#
# = test/unit/release_62/core/test_gene.rb - Unit test for Ensembl::Core
#
# Copyright::   Copyright (C) 20013 Ricardo H. Ramirez G <ricardo.ramirez-gonzalez@tgac.ac.uk>
#
# License::     Ruby's
#
# $Id:

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'ensembl'

include Ensembl::Core

class TestStableId < Test::Unit::TestCase
  
  def setup
     Ensembl::Core::DBConnection.ensemblgenomes_connect("arabidopsis_thaliana",70, {:database  => "arabidopsis_thaliana_core_17_70_10" })
  end
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_gene
    ids = %w(AT1G32045 AT3G18710 AT4G25880 AT1G71695 AT5G41480)
    genes = Gene.find_by_stable_id(ids)
    assert_equal(5,genes.size)
    #We can't assure the order. 
    assert_equal("AT1G32045", genes[0].stable_id)
    
    
    gene = Gene.find_by_stable_id("AT3G18710")
    genes = Gene.find_by_stable_id(ids)
    assert_equal("AT3G18710",gene.stable_id)
    
  end
  
  def test_exon
    exon = Exon.find_by_stable_id("AT4G25880-E.2")
    assert_equal("AT4G25880-E.2", exon.stable_id)
  end
  
 #No test for operon/operon_transcript

  
  def test_translation
    translation = Translation.find_by_stable_id("AT3G18710.1")
    assert_equal("AT3G18710.1", translation.stable_id)
    
  end
  
  def test_transcript
    transcript = Transcript.find_by_stable_id("AT3G18710.1")
    assert_equal("AT3G18710.1", transcript.stable_id)
    
    ids = %w(AT4G25880.2 AT3G18710.1 AT4G25880.3)
    transcripts = Transcript.find_all_by_stable_id(ids)
    assert_equal(3, transcripts.size)
    assert_equal("AT3G18710.1", transcript.stable_id)
    
  end
  
  
  
#   exon, gene, operon, operon_transcript, translation and transcript 
  
end