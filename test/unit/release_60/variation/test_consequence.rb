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
DBConnection.connect('homo_sapiens',60)

class TestVariation < Test::Unit::TestCase
    
  def test_intergenic  
  # INTERGENIC
    vf = VariationFeature.new(:seq_region_id => SeqRegion.find_by_name("X").seq_region_id, :seq_region_start => 23694, :seq_region_end => 23694, :seq_region_strand => 1, :allele_string => "A/T",:variation_name => "fake_SNP")
    tv = vf.transcript_variations
    assert_instance_of(TranscriptVariation,tv[0])
    assert_equal("INTERGENIC",tv[0].consequence_type)
  end  

  def test_3prime
  # 3PRIME_UTR
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 96810688, :seq_region_end => 96810688, :seq_region_strand => 1, :allele_string => "G/C", :variation_name => "rs16869283")
    tv = vf.transcript_variations
    assert_equal("3PRIME_UTR", tv[0].consequence_type) 
  end
  
  def test_5prime
  # 5PRIME_UTR
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 158536411, :seq_region_end => 158536411, :seq_region_strand => 1, :allele_string => "T/C", :variation_name => "rs71547565")
    tv = vf.transcript_variations
    assert_equal("5PRIME_UTR", tv[3].consequence_type) 
  end
  
  def test_upstream
  # UPSTREAM
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 96831018, :seq_region_end => 96831018, :seq_region_strand => 1, :allele_string => "G/T", :variation_name => "rs6975185")
    tv = vf.transcript_variations
    assert_equal("UPSTREAM",tv[0].consequence_type)
  end
  
  def test_downstream
  # DOWNSTREAM  
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 105727321, :seq_region_end => 105727321, :seq_region_strand => 1, :allele_string => "G/T", :variation_name => "rs35113830")
    tv = vf.transcript_variations
    assert_equal("DOWNSTREAM",tv[-1].consequence_type)
  end
  
  def test_mirna
  # WITHIN_MATURE_miRNA
    vf = VariationFeature.new(:seq_region_id => 27527, :seq_region_start => 175878848, :seq_region_end => 175878848, :seq_region_strand => 1, :allele_string => "C/T", :variation_name => "rs12716316")
    tv = vf.transcript_variations
    assert_equal("WITHIN_MATURE_miRNA",tv[-1].consequence_type)
  end


  def test_non_coding
  # WITHIN_NON_CODING_GENE
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 97601052, :seq_region_end => 97601052, :seq_region_strand => 1, :allele_string => "G/A", :variation_name => "rs13245475")
    tv = vf.transcript_variations
    assert_equal("WITHIN_NON_CODING_GENE",tv[1].consequence_type)
  end  

  def test_complex_indel
  # COMPLEX_INDEL
    vf = VariationFeature.new(:seq_region_id => 27515, :seq_region_start => 31902068, :seq_region_end => 31902095, :seq_region_strand => 1, :allele_string => "GTGGACAGGGTCAGGAATCAGGAGTCTG/-", :variation_name => "rs9332736")
    tv = vf.transcript_variations
    assert_equal("COMPLEX_INDEL",tv[6].consequence_type)  
  end
  
  def test_essential_splice
  # ESSENTIAL_SPLICE_SITE
    vf = VariationFeature.new(:seq_region_id => 27515, :seq_region_start => 33385862, :seq_region_end => 33385862, :seq_region_strand => 1, :allele_string => "A/G", :variation_name => "GA005718")
    tv = vf.transcript_variations
    assert_equal("ESSENTIAL_SPLICE_SITE",tv[21].consequence_type)  
  end  
    
  def test_splice_site
  # SPLICE_SITE
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 102301587, :seq_region_end => 102301587, :seq_region_strand => 1, :allele_string => "A/G", :variation_name => "rs434833")
    tv = vf.transcript_variations
    assert_equal("SPLICE_SITE",tv[5].consequence_type)  
  end

  def test_intronic
  # INTRONIC
    vf = VariationFeature.new(:seq_region_id => 27515, :seq_region_start => 31902068, :seq_region_end => 31902095, :seq_region_strand => 1, :allele_string => "GTGGACAGGGTCAGGAATCAGGAGTCTG/-", :variation_name => "rs9332736")
    tv = vf.transcript_variations
    assert_equal("INTRONIC",tv[3].consequence_type)  
  end
  
  def test_frameshift
  # FRAMESHIFT
    vf = VariationFeature.new(:seq_region_id => 27511, :seq_region_start => 78958619, :seq_region_end => 78958618, :seq_region_strand => 1, :allele_string => "-/G", :variation_name => "rs35065683")
    tv = vf.transcript_variations
    assert_equal("FRAMESHIFT_CODING",tv[1].consequence_type)
  end
  
  def test_stop_gained
  # STOP_GAINED
    vf = VariationFeature.new(:seq_region_id => 27516, :seq_region_start => 38262908, :seq_region_end => 38262908, :seq_region_strand => 1, :allele_string => "G/A", :variation_name => "rs72556299")
    tv = vf.transcript_variations
    assert_equal("STOP_GAINED",tv[-1].consequence_type)
  end
  
  def test_stop_lost  
  # STOP_LOST
    vf = VariationFeature.new(:seq_region_id => 27511, :seq_region_start => 152770613, :seq_region_end => 152770613, :seq_region_strand => 1, :allele_string => "T/G", :variation_name => "rs41268500")
    tv = vf.transcript_variations
    assert_equal("STOP_LOST",tv[0].consequence_type)
  end
  
  def test_synonymous  
  # SYNONYMOUS_CODING
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 99688238, :seq_region_end => 99688238, :seq_region_strand => 1, :allele_string => "C/T", :variation_name => "rs11550651")
    tv = vf.transcript_variations
    assert_equal("SYNONYMOUS_CODING",tv[5].consequence_type)   
  end
  
  def test_non_synonymous
  # NON_SYNONYMOUS_CODING
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 99057720, :seq_region_end => 99057720, :seq_region_strand => 1, :allele_string => "G/A", :variation_name => "rs11545970")
    tv = vf.transcript_variations
    assert_equal("NON_SYNONYMOUS_CODING",tv[9].consequence_type)
    assert_equal("A/V",tv[9].peptide_allele_string)
  end  
  
  # Checking CDNA coordinates calculation
  
  def test_genomic2cdna_fw # forward strand (variation rs67960011)
    t = Ensembl::Core::Transcript.find_by_stable_id("ENST00000039007")
    assert_equal(573,t.genomic2cdna(38260562))    
  end
  
  def test_cdna2genomic_fw # forward strand (variation rs67960011)
    t = Ensembl::Core::Transcript.find_by_stable_id("ENST00000039007")
    assert_equal(38260562,t.cdna2genomic(573))
  end
  
  def test_genomic2cdna_rev # reverse strand (variation rs11545970)
    t = Ensembl::Core::Transcript.find_by_stable_id("ENST00000422429")
    assert_equal(110,t.genomic2cdna(99057720))
  end
  
  def test_cdna2genomic_rev # reverse strand (variation rs11545970)
    t = Ensembl::Core::Transcript.find_by_stable_id("ENST00000422429")
    assert_equal(99057720,t.cdna2genomic(110))
  end


end
