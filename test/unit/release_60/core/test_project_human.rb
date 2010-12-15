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
    DBConnection.connect('homo_sapiens', 60)
  end
  
  def teardown
    DBConnection.remove_connection
  end
  
  def test_chr_x
    source_slice = Slice.fetch_by_region('chromosome','X', 2709497, 2709520)
    assert_equal('ctgaagaattgtgtttcttcccta', source_slice.seq)
  end

  def test_slice_overlapping_PAR_and_allosome
    source_slice = Slice.fetch_by_region('chromosome','Y',2709500,2709540)
    assert_equal('AGAAACTGAAAATGCTAAGAAATTCAGTTCCAGGATATGAA', source_slice.seq.upcase)
  end

end