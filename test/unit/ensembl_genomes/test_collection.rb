#
# = test/unit/release_53/ensembl_genomes/test_collection.rb - Unit test for Ensembl::Core
#
# Copyright::   Copyright (C) 2009
#               Francesco Strozzi <francesco.strozzi@gmail.com>
# License::     Ruby's
#
# $Id:

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'lib/ensembl'

include Ensembl::Core


class TestCollection < Test::Unit::TestCase
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_check_collection
    DBConnection.ensemblgenomes_connect('bacillus_collection',6)
    assert_equal(true,Collection.check)
    DBConnection.connect('homo_sapiens',56)
    assert_equal(false,Collection.check)
  end
  
  def test_check_species
    DBConnection.ensemblgenomes_connect('bacillus_collection',6)
    assert_equal(["b_subtilis",
 "b_amyloliquefaciens",
 "b_anthracis_ames",
 "b_anthracis_ames_ancestor",
 "b_anthracis_sterne",
 "b_cereus_atcc_10987",
 "b_cereus_atcc_14579",
 "b_cereus_cytotoxis",
 "b_cereus_zk",
 "b_clausii",
 "b_halodurans",
 "b_licheniformis_goettingen",
 "b_licheniformis_novozymes",
 "b_pumilus",
 "b_thuringiensis",
 "b_thuringiensis_konkukian",
 "b_weihenstephanensis",
 "b_cereus_ah820",
 "b_cereus_ah187",
 "b_cereus_03bb102",
 "b_cereus_q1",
 "b_cereus_g9842",
 "b_cereus_b4264",
 "b_anthracis_cdc_684",
 "b_anthracis_a0248"],Collection.species)
  end
  
  def test_get_species_id
    DBConnection.ensemblgenomes_connect('bacillus_collection',6)
    assert_equal(9,Collection.get_species_id("Bacillus cereus ZK"))
    assert_nil(Collection.get_species_id("Dummy specie"))  
  end
  
  def test_connection_with_a_species
    assert_nothing_raised do 
      DBConnection.ensemblgenomes_connect('b_licheniformis_goettingen',6)
    end
    assert_equal('b_licheniformis_goettingen', Ensembl::SESSION.collection_species)
  end
  
end