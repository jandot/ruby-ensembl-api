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

DBConnection.connect('homo_sapiens', 50)

# Let's see if we can 'find' things
class SimpleRecordsTest < Test::Unit::TestCase
  def setup
    @sry_gene = Gene.find(34927)
    @sry_transcript = Transcript.find(60290)
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

    assert_equal('SRY-001', @sry_transcript.display_label)
    assert_equal('SRY-001', @sry_transcript.display_name)
    assert_equal('SRY-001', @sry_transcript.label)
    assert_equal('SRY-001', @sry_transcript.name)
  end
end

class RelationshipsTest < Test::Unit::TestCase
  def test_go_terms
    gene = Gene.find(34928)
    assert_equal(["GO:0005576", "GO:0042742"], gene.go_terms.sort)
  end
  
  def test_hgnc
    gene = Gene.find_by_stable_id('ENSG00000169740')
    assert_equal('ZNF32', gene.hgnc)
  end
end
