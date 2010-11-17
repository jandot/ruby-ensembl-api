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
    DBConnection.connect('homo_sapiens',56)
  end
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_intergenic
    vf = VariationFeature.new(:seq_region_id => SeqRegion.find_by_name("X").seq_region_id, :seq_region_start => 23694, :seq_region_end => 23694, :seq_region_strand => 1, :allele_string => "A/T",:variation_name => "fake_SNP")
    tv = vf.transcript_variations
    assert_instance_of(TranscriptVariation,tv[0])
    assert_equal("INTERGENIC",tv[0].consequence_type)
  end
  
  def test_3prime_utr
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 96810688, :seq_region_end => 96810688, :seq_region_strand => 1, :allele_string => "G/C", :variation_name => "rs16869283")
    tv = vf.transcript_variations
    assert_equal("3PRIME_UTR", tv[1].consequence_type) 
  end
  
  def test_5prime_utr
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 158536411, :seq_region_end => 158536411, :seq_region_strand => 1, :allele_string => "T/C", :variation_name => "rs71547565")
    tv = vf.transcript_variations
    assert_equal("5PRIME_UTR", tv[3].consequence_type) 
  end
  
  def test_upstream
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 96831018, :seq_region_end => 96831018, :seq_region_strand => 1, :allele_string => "G/T", :variation_name => "rs6975185")
    tv = vf.transcript_variations
    assert_equal("UPSTREAM",tv[0].consequence_type)
  end
  
  def test_downstream
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 105727321, :seq_region_end => 105727321, :seq_region_strand => 1, :allele_string => "G/T", :variation_name => "rs35113830")
    tv = vf.transcript_variations
    assert_equal("DOWNSTREAM",tv[0].consequence_type)
  end
  
  def test_miRNA
    vf = VariationFeature.new(:seq_region_id => 27518, :seq_region_start => 135895002, :seq_region_end => 135895002, :seq_region_strand => 1, :allele_string => "A/G", :variation_name => "rs11266800")
    tv = vf.transcript_variations
    assert_equal("WITHIN_MATURE_miRNA",tv[2].consequence_type) 
  end
  
  def test_complex_indel_1
    vf = VariationFeature.new(:seq_region_id => 27752, :seq_region_start => 37529, :seq_region_end => 37535, :seq_region_strand => 1, :allele_string => "CCACCCA/ACACCCG", :variation_name => "rs71228679")
    tv = vf.transcript_variations
    assert_equal("COMPLEX_INDEL",tv[0].consequence_type)  
  end
  
  def test_essential_splice_site
    vf = VariationFeature.new(:seq_region_id => 27511, :seq_region_start => 818059, :seq_region_end => 818059, :seq_region_strand => 1, :allele_string => "G/T", :variation_name => "rs3888067")
    tv = vf.transcript_variations
    assert_equal("ESSENTIAL_SPLICE_SITE",tv[0].consequence_type)  
  end

  def test_splice_site
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 102301587, :seq_region_end => 102301587, :seq_region_strand => 1, :allele_string => "A/G", :variation_name => "rs434833")
    tv = vf.transcript_variations
    assert_equal("SPLICE_SITE",tv[5].consequence_type)  
  end

  def test_intronic
    vf = VariationFeature.new(:seq_region_id => 27506, :seq_region_start => 101165365, :seq_region_end => 101165365, :seq_region_strand => 1, :allele_string => "T/C", :variation_name => "rs1859633")
    tv = vf.transcript_variations
    assert_equal("INTRONIC",tv[2].consequence_type)  
  end
  
end
