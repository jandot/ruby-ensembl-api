#
# = test/unit/test_transfers.rb - Unit test for Ensembl::Core
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <http://jandot.myopenid.com>
# License::     Ruby's
#
# $Id:
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'

require 'ensembl'

include Ensembl::Core

DBConnection.connect('homo_sapiens')

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

class RelationshipsTest < Test::Unit::TestCase
  def test_go_terms
    gene = Gene.find(91283)
    assert_equal(['GO:0000166','GO:0000287','GO:0003779','GO:0004674','GO:0005515','GO:0005524','GO:0005737','GO:0006468','GO:0007243','GO:0015629','GO:0016740','GO:0051128'], gene.go_terms.sort)
  end
end
