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
require 'ensembl'

include Ensembl::Variation

class ActiveRecordVariation < Test::Unit::TestCase
  
  def setup
    DBConnection.connect('homo_sapiens',62)
  end
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_study
    s = Study.find(134)
    assert_equal(13,s.source_id)
    assert_equal("Genome-wide association study of 14,000 cases of seven common diseases and 3,000 shared controls.",s.description)
    assert_equal("pubmed/17554300",s.external_reference)
    assert_equal("GWAS",s.study_type)
    a = s.associate_studies
    assert_equal(17,a.size)

    study = Study.find_by_name "estd19"
    assert_equal("Ahn 2009 \"The first Korean genome sequence and analysis: full genome sequencing for a socio-ethnic group.\" PMID:19470904 [remapped from build NCBI36]",study.description)
    assert_equal("ftp://ftp.ebi.ac.uk/pub/databases/dgva/estd19_Ahn_et_al_2009",study.url)
    assert_equal("pubmed/19470904",study.external_reference)
    struct = study.structural_variations
    assert_equal(4281,struct.size)
    assert_equal("esv9167",struct[0].variation_name)
    assert_equal("SV",struct[0].sv_class)
    assert_equal(27515,struct[0].seq_region_id)
    assert_equal(3478018,struct[0].seq_region_start)
    assert_equal(3478196,struct[0].seq_region_end)
    
    study = Study.find(33)
    ann = study.variation_annotations
    assert_equal(17,ann.size)
    assert_equal(30235485,ann[0].variation_id)
    assert_equal("Intergenic",ann[0].associated_gene)
    assert_equal("rs11206801-A",ann[0].associated_variant_risk_allele)
    assert_equal("6E-8",ann[0].p_value)
    
  end
  
  def test_protein_info
    i = ProteinInfo.find_by_transcript_stable_id "ENST00000358183"
    position = i.protein_positions
    assert_equal(1195,position.size)
    assert_equal(1,position[0].position)
    assert_equal("M",position[0].amino_acid)
    assert_equal(4.32,position[0].sift_median_conservation)
    assert_equal(12,position[0].sift_num_sequences_represented)
  end
  
  def test_predictions
    i = ProteinInfo.find_by_transcript_stable_id "ENST00000228777"
    position = i.protein_positions[3]
    sift = position.sift_predictions[0]
    assert_equal("A",sift.amino_acid)
    assert_equal("tolerated",sift.prediction)
    assert_equal(0.05,sift.score)
    
    polyphen = position.polyphen_predictions[0]
    assert_equal("A",polyphen.amino_acid)
    assert_equal("benign",polyphen.prediction)
    assert_equal(0.006,polyphen.probability)
  end
  
  def test_structural_variation
    s = StructuralVariation.find_by_variation_name "esv9167"
    supp = s.supporting_structural_variations
    assert_equal(1,supp.size)
    assert_equal("essv31608",supp[0].name)
  end
  
end