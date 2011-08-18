#
# = test/unit/release_62/variation/test_consequence.tb - Unit test for Ensembl::Variation
#
# Copyright::   Copyright (C) 2011
#               Francesco Strozzi <francesco.strozzi@gmail.com>
# License::     Ruby's
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'ensembl'

include Ensembl::Variation
DBConnection.connect('homo_sapiens',62)

class TestVariation < Test::Unit::TestCase

  def test_3prime
    vf = VariationFeature.new(:seq_region_id => 27519, :seq_region_start => 299504, :seq_region_end => 299504, :seq_region_strand => 1, :allele_string => "T/C", :variation_name => "rs78048681")
    tv = vf.transcript_variations
    assert_equal("3_prime_UTR_variant", tv[0].consequence_types) 
  end

  def test_intergenic  
    vf = VariationFeature.new(:seq_region_id => SeqRegion.find_by_name("X").seq_region_id, :seq_region_start => 23694, :seq_region_end => 23694, :seq_region_strand => 1, :allele_string => "A/T",:variation_name => "fake_SNP")
    tv = vf.transcript_variations
    assert_instance_of(TranscriptVariation,tv[0])
    assert_equal("intergenic_variant",tv[0].consequence_types)
  end

  def test_splice_acceptor
    vf = VariationFeature.new(:seq_region_id => 27511, :seq_region_start => 1248331, :seq_region_end => 1248331, :seq_region_strand => 1, :allele_string => "T/A", :variation_name => "rs113769441")
    tv = vf.transcript_variations
    assert_equal("splice_acceptor_variant", tv[34].consequence_types)
    assert_equal("ENST00000527098",tv[43].feature_stable_id)
  end

  def test_splice_donor
    vf = VariationFeature.new(:seq_region_id => 27511, :seq_region_start => 1247605, :seq_region_end => 1247605, :seq_region_strand => 1, :allele_string => "C/G", :variation_name => "rs113643330")
    tv = vf.transcript_variations
    assert_equal("splice_donor_variant", tv[34].consequence_types)
    assert_equal("ENST00000545578",tv[34].feature_stable_id)
  end

  def test_complex_change_in_transcript
    vf = VariationFeature.new(:seq_region_id => 27509, :seq_region_start => 4837133, :seq_region_end => 4837210, :seq_region_strand => 1, :allele_string => "-/GAGCCCACCTCAGAGCCCGCCCCCAGCCCGACCACCCCG", :variation_name => "rs41439349")
    tv = vf.transcript_variations
    assert_equal("complex_change_in_transcript", tv[0].consequence_types)
    assert_equal("ENST00000438881",tv[0].feature_stable_id)
  end

  def test_stop_lost
    vf = VariationFeature.new(:seq_region_id => 27509, :seq_region_start => 4701716, :seq_region_end => 4701716, :seq_region_strand => 1, :allele_string => "G/T", :variation_name => "rs1804248")
    tv = vf.transcript_variations
    assert_equal("stop_lost", tv[0].consequence_types)
    assert_equal("ENST00000270586",tv[0].feature_stable_id)
  end

  def test_coding_sequence
    vf = VariationFeature.new(:seq_region_id => 27509, :seq_region_start => 4836003, :seq_region_end => 4836003, :seq_region_strand => 1, :allele_string => "A/HGMD_MUTATION", :variation_name => "rs1804248")
    tv = vf.transcript_variations
    assert_equal("coding_sequence_variant", tv[0].consequence_types)
    assert_equal("ENST00000438881",tv[0].feature_stable_id)
  end

  def test_non_synonymous_codon
    vf = VariationFeature.new(:seq_region_id => 27519, :seq_region_start => 313785, :seq_region_end => 313785, :seq_region_strand => 1, :allele_string => "T/C", :variation_name => "rs112982618")
    tv = vf.transcript_variations
    assert_equal("non_synonymous_codon", tv[12].consequence_types)
    assert_equal("ENST00000535347",tv[12].feature_stable_id)
    assert_equal("N/S",tv[12].pep_allele_string)
  end

  def test_stop_gained
    vf = VariationFeature.new(:seq_region_id => 27509, :seq_region_start => 4836976, :seq_region_end => 4836976, :seq_region_strand => 1, :allele_string => "G/A", :variation_name => "rs121908061")
    tv = vf.transcript_variations
    assert_equal("stop_gained", tv[1].consequence_types)
    assert_equal("ENST00000329125",tv[1].feature_stable_id)
  end

  def test_synonymous_codon
    vf = VariationFeature.new(:seq_region_id => 27519, :seq_region_start => 313751, :seq_region_end => 313751, :seq_region_strand => 1, :allele_string => "T/C", :variation_name => "rs11609900")
    tv = vf.transcript_variations
    assert_equal("synonymous_codon", tv[12].consequence_types)
    assert_equal("ENST00000535347",tv[12].feature_stable_id)
  end

  def test_frameshift_variant
    vf = VariationFeature.new(:seq_region_id => 27527, :seq_region_start => 156589990, :seq_region_end => 156589989, :seq_region_strand => 1, :allele_string => "-/C", :variation_name => "rs35703155")
    tv = vf.transcript_variations
    assert_equal("frameshift_variant", tv[-1].consequence_types)
    assert_equal("ENST00000302938",tv[-1].feature_stable_id)
  end

  def test_nc_transcript
    vf = VariationFeature.new(:seq_region_id => 27523, :seq_region_start => 43139829, :seq_region_end => 43139829, :seq_region_strand => 1, :allele_string => "G/T", :variation_name => "rs4736847")
    tv = vf.transcript_variations
    assert_equal("nc_transcript_variant", tv[0].consequence_types)
    assert_equal("ENST00000522985",tv[0].feature_stable_id)
  end

  def test_mature_miRNA
    vf = VariationFeature.new(:seq_region_id => 27504, :seq_region_start => 18204679, :seq_region_end => 18204679, :seq_region_strand => 1, :allele_string => "T/C", :variation_name => "rs10832898")
    tv = vf.transcript_variations
    assert_equal("mature_miRNA_variant", tv[1].consequence_types)
    assert_equal("ENST00000408110",tv[1].feature_stable_id)
  end

  def test_5prime
    vf = VariationFeature.new(:seq_region_id => 27509, :seq_region_start => 4835627, :seq_region_end => 4835627, :seq_region_strand => 1, :allele_string => "C/T", :variation_name => "rs56337033")
    tv = vf.transcript_variations
    assert_equal("5_prime_UTR_variant", tv[1].consequence_types)
    assert_equal("ENST00000329125",tv[1].feature_stable_id)
  end

  def test_incomplete_terminal_codon
    vf = VariationFeature.new(:seq_region_id => 27525, :seq_region_start => 118397884, :seq_region_end => 118397884, :seq_region_strand => 1, :allele_string => "A/G", :variation_name => "rs4751995")
    tv = vf.transcript_variations
    assert_equal("incomplete_terminal_codon_variant", tv[4].consequence_types)
    assert_equal("ENST00000433618",tv[4].feature_stable_id)
  end

  #def test_splice_region # THE EXAMPLES WITHIN HUMAN DATABASE CAN'T BE USED AS TEST
  #  vf = VariationFeature.new(:seq_region_id => 27505, :seq_region_start => 14743754, :seq_region_end => 14743754, :seq_region_strand => 1, :allele_string => "C/T", :variation_name => "rs74734987")
  #  tv = vf.transcript_variations
  #  tv.each {|var| puts var.consequence_types+" "+var.feature_stable_id}
  #  assert_equal("splice_region_variant", tv[0].consequence_types)
  #  assert_equal("ENST00000540061",tv[0].feature_stable_id)
  #end

  def test_intron_variant
    vf = VariationFeature.new(:seq_region_id => 27519, :seq_region_start => 312127, :seq_region_end => 312127, :seq_region_strand => 1, :allele_string => "G/T", :variation_name => "rs75380489")
    tv = vf.transcript_variations
    assert_equal("intron_variant", tv[0].consequence_types)
    assert_equal("ENST00000228777",tv[0].feature_stable_id)
  end

  def test_5KB_downstream_variant
    vf = VariationFeature.new(:seq_region_id => 27519, :seq_region_start => 300500, :seq_region_end => 300500, :seq_region_strand => 1, :allele_string => "T/C", :variation_name => "rs10128942")
    tv = vf.transcript_variations
    assert_equal("5KB_downstream_variant", tv[15].consequence_types)
    assert_equal("ENST00000535498",tv[15].feature_stable_id)
  end

  def test_2KB_upstream_variant
    vf = VariationFeature.new(:seq_region_id => 27519, :seq_region_start => 300500, :seq_region_end => 300500, :seq_region_strand => 1, :allele_string => "T/C", :variation_name => "rs10128942")
    tv = vf.transcript_variations
    assert_equal("2KB_upstream_variant", tv[-1].consequence_types)
    assert_equal("ENST00000544067",tv[-1].feature_stable_id) 
  end

  def test_5KB_upstream_variant
    vf = VariationFeature.new(:seq_region_id => 27511, :seq_region_start => 242503860, :seq_region_end => 242503860, :seq_region_strand => 1, :allele_string => "G/T", :variation_name => "rs12727465")
    tv = vf.transcript_variations
    assert_equal("5KB_upstream_variant", tv[-1].consequence_types)
    assert_equal("ENST00000447710",tv[-1].feature_stable_id)
  end
  
  def test_500B_downstream_variant
    vf = VariationFeature.new(:seq_region_id => 27523, :seq_region_start => 43139379, :seq_region_end => 43139379, :seq_region_strand => 1, :allele_string => "T/A", :variation_name => "rs114568988")
    tv = vf.transcript_variations
    assert_equal("500B_downstream_variant", tv[0].consequence_types)
    assert_equal("ENST00000522985",tv[0].feature_stable_id)
  end
  
  def test_initiator_codon_change
    vf = VariationFeature.new(:seq_region_id => 27509, :seq_region_start => 3450007, :seq_region_end => 3450007, :seq_region_strand => 1, :allele_string => "C/T", :variation_name => "rs390804")
    tv = vf.transcript_variations
    assert_equal("initiator_codon_change", tv[1].consequence_types)
    assert_equal("ENST00000430263",tv[1].feature_stable_id)
  end

  def test_stop_retained
    vf = VariationFeature.new(:seq_region_id => 27515, :seq_region_start => 138202334, :seq_region_end => 138202334, :seq_region_strand => 1, :allele_string => "G/A", :variation_name => "COSM35908")
    tv = vf.transcript_variations
    assert_equal("stop_retained_variant", tv[0].consequence_types)
    assert_equal("ENST00000535574",tv[0].feature_stable_id)
  end

  def test_inframe_codon_gain
    vf = VariationFeature.new(:seq_region_id => 27509, :seq_region_start => 636321, :seq_region_end => 636320, :seq_region_strand => 1, :allele_string => "-/CTC", :variation_name => "rs111405529")
    tv = vf.transcript_variations
    assert_equal("inframe_codon_gain", tv[1].consequence_types)
    assert_equal("ENST00000451373",tv[1].feature_stable_id)
  end

  def test_inframe_codon_loss
    vf = VariationFeature.new(:seq_region_id => 27509, :seq_region_start => 4837133, :seq_region_end => 4837210, :seq_region_strand => 1, :allele_string => "GAGCCCACCTCAGAGCCCGCCCCCAGCCCGACCACCCCGGAGCCCACCTCAGAGCCCGCCCCCAGCCCGACCACCCCA/-", :variation_name => "rs41439349")
    tv = vf.transcript_variations
    assert_equal("inframe_codon_loss", tv[1].consequence_types)
    assert_equal("ENST00000329125",tv[1].feature_stable_id)
  end

end
