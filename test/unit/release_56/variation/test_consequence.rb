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
  
  def test_custom_transcript
    vf = VariationFeature.new(:seq_region_id => SeqRegion.find_by_name("X").seq_region_id, :seq_region_start => 23694, :seq_region_end => 23694, :seq_region_strand => 1, :allele_string => "A/T",:variation_name => "fake_SNP")
    tv = vf.transcript_variations
    assert_instance_of(TranscriptVariation,tv[0])
    assert_equal("INTERGENIC",tv[0].consequence_type)
  end
  
  
end
