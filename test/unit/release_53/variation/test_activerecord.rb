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
    DBConnection.connect('homo_sapiens',53)
  end
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_allele
    allele = Allele.find(1)
    assert_equal('C', allele.allele)
    assert_equal(0.673913, allele.frequency)
  end

  def test_sample
    n = Sample.count(:all)
    assert_equal(15406,n)
    individual = Sample.find(9146).individual
    assert_equal('Female',individual.gender)
    i = Sample.find(10128).individual_genotype_multiple_bp
    assert_equal(990,i.size)
    assert_equal(1533205,i[0].variation_id)
    syn = Sample.find(21).sample_synonym
    assert_equal('477',syn.name)
  end
  
  def test_individual
    n = Individual.count(:all)
    assert_equal(8658,n)
  end
  
  def test_individual_genotype_multiple_bp
    n = IndividualGenotypeMultipleBp.count(:all)
    assert_equal(208579,n)
  end
  
  def test_compressed_genotype_single_bp
    n = CompressedGenotypeSingleBp.count(:all)
    assert_equal(12580098,n)
  end
  
  def test_read_coverage
    n = ReadCoverage.count(:all)
    assert_equal(9300776,n)
  end
  
  def test_population
    n = Population.count(:all)
    assert_equal(6748,n)
  end
  
  def test_variation
    n = Variation.count(:all)
    assert_equal(15872232,n)
    
    syn = Variation.find(84).variation_synonyms
    assert_equal(6,syn.size)
    assert_equal('TSC1239757',syn[0].name)
    
    flanking = Variation.find(10000).flanking_sequence
    assert_equal(3652320,flanking.up_seq_region_start)
    assert_equal(3652519,flanking.up_seq_region_end)
    assert_equal(3652521,flanking.down_seq_region_start)
    assert_equal(3652720,flanking.down_seq_region_end)
    assert_equal(226033,flanking.seq_region_id)
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
    assert_equal(0.593,a[0].frequency)
    
    vf = Variation.find(5345540).variation_features[0]
    assert_equal('G/A',vf.allele_string)
    assert_equal('rs8189278',vf.variation_name)
    assert_equal(226044,vf.seq_region_id)
    assert_equal(50727657,vf.seq_region_start)
    assert_equal(50727657,vf.seq_region_end)
    assert_equal(1,vf.seq_region_strand)
    
    vg = Variation.find(1352735).variation_groups
    assert_nil vg[0]
    
    i = Variation.find(1533205).individual_genotype_multiple_bps
    assert_equal(41,i.size)
  end
  
  def test_variation_feature
    vf_sample = VariationFeature.find(8).samples
    assert_equal(6,vf_sample.size)
    assert_equal('PERLEGEN:AFD_EUR_PANEL',vf_sample[0].name)
  end
  
  def test_variation_transcript
    t = Variation.find_by_name('rs35303525').variation_features[0].transcript_variations
    assert_equal(2,t.size)
    transcript = t[0].transcript
    assert_equal('protein_coding',transcript.biotype) 
    assert_equal(2199894,transcript.seq_region_start)
    assert_equal(2213658,transcript.seq_region_end)
    assert_equal('ENST00000243706',transcript.stable_id)
    e = transcript.exons
    assert_equal('CTCCCGTGAGGCAGTGCGAGGCGCGCGGGGCACGGAGGGCGGTGGCGGCGGGCTCCTGCGAGAAGCAAGCGGAACTTCCTGAG',e[0].seq.upcase)
  end
  
  def test_source
    syn = Source.find(1).sample_synonyms
    assert_equal(15385,syn.size)
    
    ag = Source.find(1).allele_groups
    assert_nil ag[0]
    
    s = Source.count(9)
    assert_equal(4,s.size)
  end
end