#
# = test/unit/test_transcript.rb - Unit test for Ensembl::Core
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

DBConnection.connect('homo_sapiens', 60)

class CodingPositions < Test::Unit::TestCase
  def setup
    # Transcript tr_fw is ENST00000215574
    @tr_fw = Transcript.find_by_stable_id("ENST00000215574")
    # Transcript tr_rev is ENST00000358041
    @tr_rev = Transcript.find_by_stable_id("ENST00000358041")
  end

  def test_transcript_coords
    assert_equal(531733, @tr_fw.seq_region_start)
    assert_equal(542084, @tr_fw.seq_region_end)
    assert_equal(644371, @tr_rev.seq_region_start)
    assert_equal(647309, @tr_rev.seq_region_end)
  end

  def test_coding_regions_genomic_coords_of_fw
    assert_equal(531932, @tr_fw.coding_region_genomic_start)
    assert_equal(541552, @tr_fw.coding_region_genomic_end)
  end

  def test_coding_regions_genomic_coords_of_rev
    assert_equal(646652, @tr_rev.coding_region_genomic_start)
    assert_equal(647047, @tr_rev.coding_region_genomic_end)
  end
  
  def test_coding_regions_cdna_coords_of_fw
    assert_equal(200, @tr_fw.coding_region_cdna_start)
    assert_equal(910, @tr_fw.coding_region_cdna_end)
  end

  def test_coding_regions_cdna_coords_of_rev
    assert_equal(263, @tr_rev.coding_region_cdna_start)
    assert_equal(658, @tr_rev.coding_region_cdna_end)
  end
  
end

class GenomicVsCDna < Test::Unit::TestCase
  #From BioMart. Columns:
  #  Ensembl_Transcript_ID
  #  Chromosome
  #  Strand
  #  Ensembl_Exon_ID
  #  Exon_Chr_Start
  #  Exon_Chr_End
  #  Exon_Rank_in_Transcript
  #ENST00000215574	19	1	ENSE00000655676	531733	532108	1
  #ENST00000215574	19	1	ENSE00000655677	535837	535923	2
  #ENST00000215574	19	1	ENSE00000655678	536243	536340	3
  #ENST00000215574	19	1	ENSE00000655679	537013	537147	4
  #ENST00000215574	19	1	ENSE00000655680	541339	542084	5
  #
  #ENST00000315489	19	-1	ENSE00001215510	474621	474983	1
  #ENST00000315489	19	-1	ENSE00001215495	472394	472501	2
  #ENST00000315489	19	-1	ENSE00001215487	467649	467762	3
  #ENST00000315489	19	-1	ENSE00001215506	463344	464364	4
  def setup
    # Transcript tr_fw is ENST00000215574
    @tr_fw = Transcript.find_by_stable_id("ENST00000215574")
    # Transcript tr_rev is ENST00000315489
    @tr_rev = Transcript.find_by_stable_id("ENST00000315489")
  end
  
  def test_identify_exon
    assert_equal("ENSE00000655679", @tr_fw.exon_for_cdna_position(601).stable_id)
    assert_equal("ENSE00000655679", @tr_fw.exon_for_genomic_position(537052).stable_id)
    assert_equal("ENSE00001215487", @tr_rev.exon_for_cdna_position(541).stable_id)
    assert_equal("ENSE00001215487", @tr_rev.exon_for_genomic_position(467693).stable_id)
  end
  
  def test_cdna2genomic
    assert_equal(537052, @tr_fw.cdna2genomic(601))
    assert_equal(467693, @tr_rev.cdna2genomic(541))
  end
  
  def test_cds2genomic
    assert_equal(537052, @tr_fw.cds2genomic(401))
    assert_equal(467693, @tr_rev.cds2genomic(304))
  end
  
  def test_genomic2cdna
    assert_equal(601, @tr_fw.genomic2cdna(537052))
    assert_equal(541, @tr_rev.genomic2cdna(467693))
  end
  
  def test_genomic2cds
    assert_equal(401, @tr_fw.genomic2cds(537052))
    assert_equal(304, @tr_rev.genomic2cds(467693))
  end
end

class TestIntron < Test::Unit::TestCase
  def setup
    @transcript = Transcript.find_by_stable_id("ENST00000215574")
    @introns = @transcript.introns
  end
  
  def test_get_introns
    assert_equal(4, @introns.length)
  end
  
  def test_intron_slices
    assert_equal('chromosome:GRCh37:19:532109:535836:1', @introns[0].slice.to_s)
  end
end

