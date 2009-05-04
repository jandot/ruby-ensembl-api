#
# = test/unit/test_project.rb - Unit test for Ensembl::Core
#
# Copyright::   Copyright (C) 2009
#               Jan Aerts <http://jandot.myopenid.com>
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

class AssemblyExceptions < Test::Unit::TestCase
  
  def setup
    DBConnection.connect('homo_sapiens', 53)
  end
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_chr_x
    source_slice = Slice.fetch_by_region('chromosome','X', 2709497, 2709520)
    assert_equal('tagttatagattaaaagaagttaa', source_slice.seq)
  end

  def test_slice_overlapping_PAR_and_allosome
    source_slice = Slice.fetch_by_region('chromosome','Y',2709500,2709540)
    target_slices = source_slice.project('contig')
    assert_equal('contig::AC006209.25.1.141759:23323:23343:-1', target_slices[0].display_name)
    assert_equal('contig::AC006040.3.1.186504:57272:57291:1', target_slices[1].display_name)
  end

  def test_seq_slice_overlapping_PAR
    seq = ''
    File.open("test/unit/data/seq_y.fa").reject{|l| l=~/^>/}.each do |line|
      line.chomp!
      seq += line
    end
    seq.downcase!

    source_slice = Slice.fetch_by_region('chromosome', 'Y', 2709497, 2709542)
    assert_equal(seq.downcase, source_slice.seq)
  end

  # The MHC haplotypes for human are not implemented yet, so we raise an error
  # in the code.
  def test_seq_slice_overlapping_HAP
    seq = ''
    File.open('test/unit/data/seq_c6qbl.fa').reject{|l| l=~/^>/}.each do |line|
      line.chomp!
      seq += line
    end
    seq.downcase!

    source_slice = Slice.fetch_by_region('chromosome', 'c6_QBL', 33451191, 33451690)
    assert_raise(NotImplementedError) {source_slice.seq}
  end
end