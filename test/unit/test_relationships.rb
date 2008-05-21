#
# = test/unit/test_transfers.rb - Unit test for Ensembl::Core
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     Ruby's
#
# $Id:
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 2, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'

require 'ensembl'

include Ensembl::Core

CoreDBConnection.connect('homo_sapiens')

# Let's see if we can 'find' things
class SimpleRecordsTest < Test::Unit::TestCase
  def setup
    @sry_gene = Gene.find(85743)
    @sry_transcript = Transcript.find(271533)
  end

  def test_coord_system
    coord_system = CoordSystem.find(17)
    assert_equal('chromosome', coord_system.name)
  end

  def test_coord_system_toplevel
    coord_system = CoordSystem.find_toplevel
    assert_equal('chromosome', coord_system.name)
  end

  def test_coord_system_seqlevel
    coord_system = CoordSystem.find_seqlevel
    assert_equal('contig', coord_system.name)
  end

  def test_display_label
    assert_equal('SRY', @sry_gene.display_label)
    assert_equal('SRY', @sry_gene.display_name)
    assert_equal('SRY', @sry_gene.label)
    assert_equal('SRY', @sry_gene.name)
    
    assert_equal('SRY_HUMAN', @sry_transcript.display_label)
    assert_equal('SRY_HUMAN', @sry_transcript.display_name)
    assert_equal('SRY_HUMAN', @sry_transcript.label)
    assert_equal('SRY_HUMAN', @sry_transcript.name)
  end
end
