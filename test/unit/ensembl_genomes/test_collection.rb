#
#
# Copyright::   Copyright (C) 2011
#               Francesco Strozzi <francesco.strozzi@gmail.com>
# License::     Ruby's
#
# $Id:

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'ensembl'

include Ensembl::Core


class TestCollection < Test::Unit::TestCase
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_check_collection
    DBConnection.ensemblgenomes_connect('bacillus_collection',8)
    assert_equal(true,Collection.check)
    DBConnection.connect('homo_sapiens',56)
    assert_equal(false,Collection.check)
  end
  
  def test_check_species
    DBConnection.ensemblgenomes_connect('bacillus_collection',8)
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
     "b_anthracis_a0248",
     "b_thuringiensis_bt407",
     "b_thuringiensis_ibl200",
     "b_mycoides_rock1_4",
     "b_thuringiensis_bgsc_4ba1_pondicheri",
     "b_cereus_f65185",
     "b_thuringiensis_bgsc_4bd1_huazhong",
     "b_selenitireducens",
     "b_cereus_r309803",
     "b_cereus_bdrd_st196",
     "b_thuringiensis_bgsc_4cc1_pulsiensis",
     "b_cereus_95_8201",
     "b_cereus_bdrd_st24",
     "b_cereus_ah676",
     "b_cereus_bdrd_st26",
     "b_cereus_m1293",
     "b_thuringiensis_atcc_10792",
     "b_cereus_rock1_15",
     "b_cereus_ah1273",
     "b_thuringiensis_bgsc_4y1_tochigiensis",
     "b_thuringiensis_t13001_pakistani",
     "b_cereus_ah621",
     "b_mycoides_dsm_2048",
     "b_cereus_rock3_44",
     "b_cereus_ah603",
     "b_cereus_172560w",
     "b_cereus_rock3_29",
     "b_cereus_mm3",
     "b_cereus_ah1272",
     "b_pseudofirmus",
     "b_cereus_rock4_18",
     "b_thuringiensis_bgsc_4aw1_andalous",
     "b_cereus_rock3_28",
     "b_pseudomycoides",
     "b_mycoides_rock3_17",
     "b_thuringiensis_t01001",
     "b_thuringiensis_t04001_sotto",
     "b_cereus_bdrd_bcer4",
     "b_thuringiensis_t03a001_kurstaki",
     "b_thuringiensis_ibl4222",
     "b_cereus_mm1550",
     "b_cereus_bgsc_6e1",
     "b_thuringiensis_bmb171",
     "b_cereus_var_anthracis",
     "b_cereus_atcc_10876",
     "b_cereus_ah1271",
     "b_cereus_atcc_4342",
     "b_megaterium_atcc_12872",
     "b_thuringiensis_bgsc_4aj1",
     "b_cereus_rock4_2",
     "b_cereus_rock3_42",
     "b_cereus_rock1_3",
     "b_tusciae",
     "b_megaterium_dsm_319"],Collection.species)
  end
  
  def test_get_species_id
    DBConnection.ensemblgenomes_connect('bacillus_collection',8)
    assert_equal(9,Collection.get_species_id("Bacillus cereus ZK"))
    assert_nil(Collection.get_species_id("Dummy specie"))  
  end
  
  def test_connection_with_a_species
    assert_nothing_raised do 
      DBConnection.ensemblgenomes_connect('b_licheniformis_goettingen',8)
    end
    assert_equal('b_licheniformis_goettingen', Ensembl::SESSION.collection_species)
  end
  
end