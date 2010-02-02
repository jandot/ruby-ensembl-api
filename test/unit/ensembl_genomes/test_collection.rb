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
    DBConnection.ensemblgenomes_connect('bacillus_collection',3)
    assert_equal(true,Collection.check)
    DBConnection.connect('homo_sapiens',56)
    assert_equal(false,Collection.check)
  end
  
  def test_check_species
    DBConnection.ensemblgenomes_connect('bacillus_collection',3)
    assert_equal(["Bacillus subtilis","Bacillus amyloliquefaciens","Bacillus anthracis Ames","Bacillus anthracis Ames ancestor","Bacillus anthracis Sterne","Bacillus cereus ATCC 10987","Bacillus cereus ATCC 14579","Bacillus cereus NVH 391-98","Bacillus cereus ZK","Bacillus clausii","Bacillus halodurans","Bacillus licheniformis Goettingen","Bacillus licheniformis Novozymes","Bacillus pumilus SAFR-032","Bacillus thuringiensis Al Hakam","Bacillus thuringiensis konkukian 97-27","Bacillus weihenstephanensis","Bacillus cereus AH820","Bacillus cereus AH187","Bacillus cereus Q1","Bacillus cereus G9842","Bacillus cereus B4264"],Collection.species)
  end
  
  def test_get_species_id
    DBConnection.ensemblgenomes_connect('bacillus_collection',3)
    assert_equal(9,Collection.get_species_id("Bacillus cereus ZK"))
    assert_nil(Collection.get_species_id("Dummy specie"))  
  end
  
  def test_connection_with_a_species
    assert_nothing_raised do 
      DBConnection.ensemblgenomes_connect('Bacillus_licheniformis_Goettingen',3)
    end
    assert_equal('bacillus licheniformis goettingen', Ensembl::SESSION.collection_species)
  end
  
end