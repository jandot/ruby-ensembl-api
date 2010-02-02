#
# = test/unit/release_50/variation/test_activerecord.rb - Unit test for Ensembl::Variation
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
    DBConnection.connect('homo_sapiens',56)
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
    assert_equal(17822,n)
    individual = Sample.find(12468).individual
    assert_equal('Male',individual.gender)
    i = Sample.find(13131).individual_genotype_multiple_bp
    assert_equal(3,i.size)
    assert_equal(17510,i[0].variation_id)
    syn = Sample.find(21).sample_synonym
    assert_equal('477',syn.name)
  end
  
  def test_individual
    n = Individual.count(:all)
    assert_equal(10132,n)
  end
  
  def test_individual_genotype_multiple_bp
    n = IndividualGenotypeMultipleBp.count(:all)
    assert_equal(712267,n)
  end
  
  def test_compressed_genotype_single_bp
    n = CompressedGenotypeSingleBp.count(:all)
    assert_equal(12736658,n)
  end
  
  def test_read_coverage
    n = ReadCoverage.count(:all)
    assert_equal(6521608,n)
  end
  
  def test_population
    n = Population.count(:all)
    assert_equal(7690,n)
  end
  
  def test_variation
    n = Variation.count(:all)
    assert_equal(18909925,n)
    
    syn = Variation.find(712422).variation_synonyms
    assert_equal(6,syn.size)
    assert_equal('SNP_A-1507972',syn[0].name)
    
    flanking = Variation.find(10000).flanking_sequence
    assert_equal(3705521,flanking.up_seq_region_start)
    assert_equal(3705770,flanking.up_seq_region_end)
    assert_equal(3705772,flanking.down_seq_region_start)
    assert_equal(3706021,flanking.down_seq_region_end)
    assert_equal(27509,flanking.seq_region_id)
    assert_equal(1,flanking.seq_region_strand)
    
    ag = Variation.find(10000).allele_groups
    assert_nil ag[0]
    
    pg = Variation.find(10000).population_genotypes
    assert_equal(12,pg.size)
    assert_equal('C',pg[0].allele_1)
    assert_equal('C',pg[0].allele_2)
    assert_equal(1,pg[0].frequency)
    
    a = Variation.find(115).alleles
    assert_equal(8,a.size)
    assert_equal('C',a[0].allele)
    assert_equal(0.733,a[0].frequency)
    
    vf = Variation.find(5345540).variation_features[0]
    assert_equal('T/A',vf.allele_string)
    assert_equal('rs8189747',vf.variation_name)
    assert_equal(27526,vf.seq_region_id)
    assert_equal(24606076,vf.seq_region_start)
    assert_equal(24606076,vf.seq_region_end)
    assert_equal(1,vf.seq_region_strand)
    
    vg = Variation.find(1352735).variation_groups
    assert_nil vg[0]
    
    i = Variation.find(1533176).individual_genotype_multiple_bps
    assert_equal(42,i.size)
  end
  
  def test_variation_feature
    vf_sample = VariationFeature.find(38461).samples
    assert_equal(8,vf_sample.size)
    assert_equal('PERLEGEN:AFD_EUR_PANEL',vf_sample[0].name)
  end
  
  def test_variation_transcript
    t = Variation.find_by_name('rs7671997').variation_features[0].transcript_variations
    assert_equal(2,t.size)
    transcript = t[0].transcript
    assert_equal('protein_coding',transcript.biotype)
    assert_equal(2230096,transcript.seq_region_start)
    assert_equal(2243860,transcript.seq_region_end)
    assert_equal('ENST00000243706',transcript.stable_id)
    e = transcript.exons
    assert_equal('CTCCCGTGAGGCAGTGCGAGGCGCGCGGGGCACGGAGGGCGGTGGCGGCGGGCTCCTGCGAGAAGCAAGCGGAACTTCCTGAG',e[0].seq.upcase)
  end
  
  def test_source
    syn = Source.find(1).sample_synonyms
    assert_equal(17806,syn.size)
    
    ag = Source.find(1).allele_groups
    assert_nil ag[0]
  end
end