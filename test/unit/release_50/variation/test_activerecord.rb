#
# = test/unit/test_seq.rb - Unit test for Ensembl::Core
#
# Copyright::   Copyright (C) 2008
#               Jan Aerts <http://jandot.myopenid.com>
# License::     Ruby's
#
# $Id:
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'ensembl'

include Ensembl::Variation

DBConnection.connect('homo_sapiens')

class ActiveRecordVariation < Test::Unit::TestCase
  def test_allele
    allele = Allele.find(1)
    assert_equal('T', allele.allele)
    assert_equal(0.04, allele.frequency)
  end
  
  def test_allele_group
    n = AlleleGroup.count(:all)
    assert_equal(0, n)
  end

  def test_sample
    n = Sample.count(:all)
    assert_equal(12385,n)
    individual = Sample.find(5499).individual
    assert_equal('Male',individual.gender)
    i = Sample.find(6201).individual_genotype_multiple_bp
    assert_equal(1256,i.size)
    assert_equal(548383,i[0].variation_id)
    syn = Sample.find(17).sample_synonym
    assert_equal('5',syn.name)
  end
  
  def test_individual
    n = Individual.count(:all)
    assert_equal(7769,n)
  end
  
  def test_individual_genotype_multiple_bp
    n = IndividualGenotypeMultipleBp.count(:all)
    assert_equal(835033,n)
  end
  
  def test_compressed_genotype_single_bp
    n = CompressedGenotypeSingleBp.count(:all)
    assert_equal(12473477,n)
  end
  
  def test_read_coverage
    n = ReadCoverage.count(:all)
    assert_equal(9328349,n)
  end
  
  def test_population
    n = Population.count(:all)
    assert_equal(4616,n)
  end
  
  def test_variation
    n = Variation.count(:all)
    assert_equal(13383219,n)
    
    syn = Variation.find(27).variation_synonym
    assert_equal('SNP001745772',syn.name)
    
    flanking = Variation.find(130).flanking_sequence
    assert_equal(24910767,flanking.up_seq_region_start)
    assert_equal(24911281,flanking.up_seq_region_end)
    assert_equal(24911283,flanking.down_seq_region_start)
    assert_equal(24911367,flanking.down_seq_region_end)
    assert_equal(226030,flanking.seq_region_id)
    assert_equal(1,flanking.seq_region_strand)
    
    ag = Variation.find(130).allele_groups
    assert_nil ag[0]
    
    pg = Variation.find(1125).population_genotypes
    assert_equal(26,pg.size)
    assert_equal('A',pg[0].allele_1)
    assert_equal('A',pg[0].allele_2)
    assert_equal(0.2,pg[0].frequency)
    
    a = Variation.find(115).alleles
    assert_equal(8,a.size)
    assert_equal('C',a[0].allele)
    assert_equal(0.733,a[0].frequency)
    
    vf = Variation.find(5345540).variation_feature
    assert_equal('G/A',vf.allele_string)
    assert_equal('rs8175337',vf.variation_name)
    assert_equal(226028,vf.seq_region_id)
    assert_equal(10052344,vf.seq_region_start)
    assert_equal(10052344,vf.seq_region_end)
    assert_equal(1,vf.seq_region_strand)
    
    vg = Variation.find(1352735).variation_groups
    assert_nil vg[0]
    
    i = Variation.find(1352735).individual_genotype_multiple_bps
    assert_equal(31,i.size)
  end
  
  def test_variation_feature
    vf_sample = VariationFeature.find(4571).samples
    assert_equal(5,vf_sample.size)
    assert_equal('PERLEGEN:AFD_EUR_PANEL',vf_sample[0].name)
  end
  
  def test_variation_transcript
    t = Variation.find(10958566).variation_feature.transcript_variations
    assert_equal(5,t.size)
    assert_equal(69644,t[0].transcript_id)
  end
  
  def test_source
    syn = Source.find(1).sample_synonyms
    assert_equal('2',syn[0].name)
    
    ag = Source.find(1).allele_groups
    assert_nil ag[0]
    
    v = Source.find(6).variations
    assert_equal(19,v.size)
    assert_equal('SNP_A-8319323',v[0].name)
  end
end