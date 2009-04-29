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

class TestSlice < Test::Unit::TestCase
  
  def test_fetch_by_region
    DBConnection.connect('mycobacterium_collection',1,:host => "mysql.ebi.ac.uk",:port => 4157)
    slice = Slice.fetch_by_region('chromosome',"Chromosome",183617,183716,1,"Mycobacterium tuberculosis H37Rv")
    assert_equal("GCGCCATGACAGATCCGCAGACGCAGAGCACCAGGGTCGGGGTGGTTGCCGAGTCGGGGCCCGACGAACGACGGGTCGCGCTGGTTCCCAAGGCGGTCGC",slice.seq.upcase)
    
    slice = Slice.fetch_by_region('chromosome',"Chromosome",4285422,4285521,1,"Mycobacterium paratuberculosis")
    assert_equal("GGTGTTAACGGCCGAAAGGTGGTTGAAAGATCGGCGGAATCGGGCGCACCCGGGTGGTCGTCGACGCCGCGCTGGTGGTGCTCGGCTGCGCCGTCGTGGT",slice.seq.upcase)
    
    slice = Slice.fetch_by_region('chromosome',"Chromosome",2667164,2667263,1,"Mycobacterium paratuberculosis")
    assert_equal("GTTCCACCTGCCGATCGTCTTCCTCGCCGATAACCCGGGCATGCTGCCCGGCAGCCGGTCCGAACGCAGCGGTGTGCTGCGCGCCGGCGCGCGGATGTTC",slice.seq.upcase)
  end
  
  def test_fetch_genes_from_slice
    DBConnection.connect('mycobacterium_collection',1,:host => "mysql.ebi.ac.uk",:port => 4157)
    slice = Slice.fetch_by_region('chromosome',"Chromosome",620900,622130 ,1,"Mycobacterium tuberculosis H37Rv")
    genes = slice.genes
    assert_equal("EBMYCG00000001929",genes[0].stable_id)
    
    slice = Slice.fetch_by_region('chromosome',"Chromosome",923890,925120 ,1,"Mycobacterium paratuberculosis")
    genes = slice.genes
    assert_equal("EBMYCG00000037956",genes[0].stable_id)
  end
  
  def test_new_db_and_reverse_slice
    DBConnection.connect('escherichia_shigella_collection',1,:host => "mysql.ebi.ac.uk",:port => 4157)
    slice = Slice.fetch_by_region('chromosome',"Chromosome",831691,831790,-1,"Escherichia coli K12")
    assert_equal("AAACGATGCTTACTGGGGAGACGGTGGTCATGGTAAGGGCAAGAATCGACTGGGCTACCTTTTAATGGAGTTGCGCGAACAATTGGCTATAGAGAAGTAA",slice.seq.upcase)
    
    slice = Slice.fetch_by_region('chromosome',"Chromosome",831690,832175,-1,"Escherichia coli K12")
    genes = slice.genes
    assert_equal("EBESCG00000001341",genes[0].stable_id)
  end
  
  def test_fetch_all
    DBConnection.connect('bacillus_collection',1,:host => "mysql.ebi.ac.uk", :port => 4157)
    slices = Slice.fetch_all('chromosome',"Bacillus anthracis Sterne")
    assert_equal(5228663,slices[0].length)
  end
  
  def test_error_species
    DBConnection.connect('bacillus_collection',1,:host => "mysql.ebi.ac.uk", :port => 4157)
    assert_raise ArgumentError do 
      Slice.fetch_by_region('chromosome',"Chromosome",831690,832175,1,"Wrong specie name")
    end
  end

end