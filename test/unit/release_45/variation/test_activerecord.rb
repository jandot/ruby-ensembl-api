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
require 'yaml'
require 'ensembl'

include Ensembl::Variation

DBConnection.connect('homo_sapiens')

class Simple < Test::Unit::TestCase
  def test_allele
    allele = Allele.find(1)
    assert_equal('T', allele.allele)
    assert_equal(0.04, allele.frequency)
  end
  
  def test_allele_group
    allele_group = AlleleGroup.find(1)
    assert_equal('ABDR-1', allele_group.name)
  end
end