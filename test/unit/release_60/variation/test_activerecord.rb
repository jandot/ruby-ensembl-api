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
    p = Population.find(236)
    ind = p.individuals
    assert_equal(653,ind.size)
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
  
  def test_variation_annotation
    va = VariationAnnotation.find(95)
    assert_equal(1756227,va.variation_id)
    assert_equal('EGAS00000000060',va.local_stable_id)
    assert_equal('rs2306027',va.variation_names)
    assert_equal(0.218132812399633,va.risk_allele_freq_in_controls.to_f)    
  end
  
  def test_phenotype
    pheno = Phenotype.find(1527)
    va = pheno.variation_annotations
    assert_equal(14,va.size)
    assert_equal('GATA6,CTAGE1,RBBP8,CABLES1',va[5].associated_gene)
  end
  
  def test_structural_variation
    sv = StructuralVariation.find(171276)
    assert_equal('nsv429550',sv.variation_name)
    assert_equal(224676,sv.seq_region_start)
    assert_equal(44780026,sv.seq_region_end)
    assert_equal('11',sv.seq_region.name)
  end
  
  def test_population_genotype
    v = Variation.find(1082)
    pg = v.population_genotypes
    assert_equal(41,pg.size)
    assert_equal(0.6,pg[0].frequency)
    pop = Population.find(132)
    pg = pop.population_genotypes
    assert_equal(1070,pg.size)
  end
  
  def test_subsnp_handle
    s = SubsnpHandle.find(946)
    assert_equal('WIAF',s.handle)
    pg = s.population_genotypes
    assert_equal(2,pg.size)
    assert_equal(0.4,pg[0].frequency)
    alleles = s.alleles
    assert_equal(2,alleles.size)
    assert_equal('A',alleles[0].allele)
    s = SubsnpHandle.find(107935890)
    vs = s.variation_synonyms
    assert_equal(1,vs.size)
    assert_equal('ENSSNP10154320',vs[0].name)
  end
  
  def test_variation_synonym
    v = Variation.find(12659557)
    vs = v.variation_synonyms
    assert_equal(1,vs.size)
    assert_equal('rs66792216',vs[0].name)
  end
  
  def test_failed_description
    v = Variation.find(15005920)
    fd = v.failed_descriptions
    assert_equal(1,fd.size)
    assert_equal('Variation maps to more than 3 different locations',fd[0].description)
  end
  
  
end