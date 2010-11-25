#
# = test/unit/release_56/variation/test_activerecord.rb - Unit test for Ensembl::Variation
#
# Copyright::   Copyright (C) 2009
#               Francesco Strozzi <francesco.strozzi@gmail.com>
#
# License::     Ruby's
#
# $Id:
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'lib/ensembl'

include Ensembl::Variation

class ActiveRecordVariation < Test::Unit::TestCase
  
  def setup
    DBConnection.connect('homo_sapiens',60)
  end
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_allele
    allele = Allele.find(1)
    assert_equal('T', allele.allele)
    assert_equal(0.04, allele.frequency)
  end

  def test_sample
    n = Sample.count(:all)
    assert_equal(30351,n)
    individual = Sample.find(12468).individual
    assert_equal('Male',individual.gender)
    i = Sample.find(13131).individual_genotype_multiple_bp
    assert_equal(5,i.size)
    assert_equal(1688213,i[0].variation_id)
    syn = Sample.find(21).sample_synonym
    assert_equal('6',syn.name)
  end
  
  def test_individual
    n = Individual.count(:all)
    assert_equal(12307,n)
  end
  
  def test_individual_genotype_multiple_bp
    n = IndividualGenotypeMultipleBp.count(:all)
    assert_equal(1009778,n)
  end
  
  def test_compressed_genotype_single_bp
    n = CompressedGenotypeSingleBp.count(:all)
    assert_equal(67856517,n)
  end
  
  def test_read_coverage
    n = ReadCoverage.count(:all)
    assert_equal(4183832,n)
  end
  
  def test_population
    n = Population.count(:all)
    assert_equal(11673,n)
  end
  
  def test_variation
    n = Variation.count(:all)
    assert_equal(24623913,n)
    
    syn = Variation.find(712422).variation_synonyms
    assert_equal(1,syn.size)
    assert_equal('rs56673311',syn[0].name)
    
    flanking = Variation.find(10000).flanking_sequence
    assert_equal(132077099,flanking.up_seq_region_start)
    assert_equal(132077128,flanking.up_seq_region_end)
    assert_equal(132077130,flanking.down_seq_region_start)
    assert_equal(132077159,flanking.down_seq_region_end)
    assert_equal(27517,flanking.seq_region_id)
    assert_equal(1,flanking.seq_region_strand)
    
    ag = Variation.find(10000).allele_groups
    assert_nil ag[0]
    
    pg = Variation.find(1234).population_genotypes
    assert_equal(28,pg.size)
    assert_equal('A',pg[0].allele_1)
    assert_equal('A',pg[0].allele_2)
    assert_equal(1,pg[0].frequency)
    
    a = Variation.find(115).alleles
    assert_equal(14,a.size)
    assert_equal('C',a[0].allele)
    assert_equal(0.733,a[0].frequency)
    
    vf = Variation.find(5345540).variation_features[0]
    assert_equal('C/T',vf.allele_string)
    assert_equal('rs8192830',vf.variation_name)
    assert_equal(27506,vf.seq_region_id)
    assert_equal(139618573,vf.seq_region_start)
    assert_equal(139618573,vf.seq_region_end)
    assert_equal(1,vf.seq_region_strand)
    
    vg = Variation.find(1352735).variation_groups
    assert_nil vg[0]
    
    i = Variation.find(243).individual_genotype_multiple_bps
    assert_equal(68,i.size)
  end
  
  def test_variation_feature
    vf_sample = VariationFeature.find_by_variation_name('rs167125').samples
    assert_equal(1,vf_sample.size)
    assert_equal('CSHL-HAPMAP:HapMap-JPT',vf_sample[0].name)
  end
  
  def test_variation_transcript
    t = Variation.find_by_name('rs7671997').variation_features[0].transcript_variations
    assert_equal(7,t.size)
    assert_equal('WITHIN_NON_CODING_GENE',t[0].consequence_type)
    assert_equal('5PRIME_UTR',t[2].consequence_type)
    assert_equal(4079207,t[0].variation_feature_id)
    transcript = t[0].transcript
    assert_equal('processed_transcript',transcript.biotype)
    assert_equal(2158121,transcript.seq_region_start)
    assert_equal(2243848,transcript.seq_region_end)
    assert_equal('ENST00000515357',transcript.stable_id)
    e = transcript.exons
    assert_equal('AGTGCGAGGCGCGCGGGGCACGGAGGGCGGTGGCGGCGGGCTCCTGCGAGAAGCAAGCGGAACTTCCTGAG',e[0].seq.upcase)

  end
  
  def test_source
    syn = Source.find(1).sample_synonyms
    assert_equal(23061,syn.size)
    
    ag = Source.find(1).allele_groups
    assert_nil ag[0]
  end
end