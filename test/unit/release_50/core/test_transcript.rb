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

require 'lib/ensembl'

include Ensembl::Core

DBConnection.connect('homo_sapiens', 50)

class CodingPositions < Test::Unit::TestCase
  def setup
    # Transcript tr_fw is ENST00000215574
    @tr_fw = Transcript.find(73491)
    # Transcript tr_rev is ENST00000358041
    @tr_rev = Transcript.find(73774)
  end

  def test_transcript_coords
    assert_equal(482733, @tr_fw.seq_region_start)
    assert_equal(493084, @tr_fw.seq_region_end)
    assert_equal(595371, @tr_rev.seq_region_start)
    assert_equal(598309, @tr_rev.seq_region_end)
  end

  def test_coding_regions_genomic_coords_of_fw
    assert_equal(482932, @tr_fw.coding_region_genomic_start)
    assert_equal(492552, @tr_fw.coding_region_genomic_end)
  end

  def test_coding_regions_genomic_coords_of_rev
    assert_equal(597652, @tr_rev.coding_region_genomic_start)
    assert_equal(598047, @tr_rev.coding_region_genomic_end)
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
  #  Gene_Start
  #  Gene_End
  #  Transcript_Start
  #  Transcript_End
  #  Strand
  #  Gene
  #  Exon_Chr_Start
  #  Exon_Chr_End
  #  Exon_Rank_in_Transcript
  #  phase
  #ENST00000215574	19	482733	493084	482733	493084	1	CDC34	482733	483108	1	-1
  #ENST00000215574	19	482733	493084	482733	493084	1	CDC34	486837	486923	2	0
  #ENST00000215574	19	482733	493084	482733	493084	1	CDC34	487243	487340	3	0
  #ENST00000215574	19	482733	493084	482733	493084	1	CDC34	488013	488147	4	2
  #ENST00000215574	19	482733	493084	482733	493084	1	CDC34	492339	493084	5	2
  #
  #ENST00000315489	19	414360	425983	414360	425983	-1	C19orf19	425621	425983	1	-1
  #ENST00000315489	19	414360	425983	414360	425983	-1	C19orf19	423394	423501	2	1
  #ENST00000315489	19	414360	425983	414360	425983	-1	C19orf19	418649	418762	3	1
  #ENST00000315489	19	414360	425983	414360	425983	-1	C19orf19	414360	415364	4	1
  def setup
    # Transcript tr_fw is ENST00000215574
    @tr_fw = Transcript.find(73491)
    # Transcript tr_rev is ENST00000315489
    @tr_rev = Transcript.find(73411)
  end
  
  def test_identify_exon
    assert_equal(Exon.find(374767), @tr_fw.exon_for_cdna_position(601))
    assert_equal(Exon.find(374767), @tr_fw.exon_for_genomic_position(488053))
    assert_equal(Exon.find(374458), @tr_rev.exon_for_cdna_position(541))
    assert_equal(Exon.find(374458), @tr_rev.exon_for_genomic_position(418719))
  end
  
  def test_cdna2genomic
    assert_equal(488052, @tr_fw.cdna2genomic(601))
    assert_equal(418693, @tr_rev.cdna2genomic(541))
  end
  
  def test_cds2genomic
    assert_equal(488052, @tr_fw.cds2genomic(401))
    assert_equal(418693, @tr_rev.cds2genomic(304))
  end
  
  def test_genomic2cdna
    assert_equal(601, @tr_fw.genomic2cdna(488052))
    assert_equal(541, @tr_rev.genomic2cdna(418693))
  end
  
  def test_genomic2cds
    assert_equal(401, @tr_fw.genomic2cds(488052))
    assert_equal(304, @tr_rev.genomic2cds(418693))
  end
end

class TestIntron < Test::Unit::TestCase
  def setup
    @transcript = Transcript.find(58973)
    @introns = @transcript.introns
  end
  
  def test_get_introns
    assert_equal(2, @introns.length)
  end
  
  def test_intron_slices
    assert_equal('chromosome:NCBI36:8:159418:172128:-1', @introns[0].slice.to_s)
  end
end

