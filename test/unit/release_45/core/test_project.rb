#
# = test/unit/test_project.rb - Unit test for Ensembl::Core
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

DBConnection.connect('bos_taurus')

class CoordinateMappingsTestSimple < Test::Unit::TestCase
  # First see if the relationships work
  def test_assemblies
    # Scaffold Chr4.003.105 should only be a component of chromosome 4
    scaffold_coord_system = CoordSystem.find_by_name('scaffold')
    chr4_105 = SeqRegion.find_by_name_and_coord_system_id('Chr4.003.105', scaffold_coord_system.id)
    assert_equal(1, chr4_105.assembled_seq_regions.length)

    # Chromosome 4 has 4118 components (127 scaffolds and 3991 contigs)
    chr_coord_system = CoordSystem.find_by_name('chromosome')
    chr4 = SeqRegion.find_by_name_and_coord_system_id('4', chr_coord_system.id)
    assert_equal(4118, chr4.component_seq_regions.length)

    # Chromosome 4 has 127 scaffolds
    assert_equal(127, chr4.component_seq_regions('scaffold').length)

    # Positions of the link between Chr4 and Chr4.003.105
    # * Scaffold Chr4.003.105 starts at position 96652111 on chromosome Chr4
    # * Scaffold Chr4.003.105 does not have links as assembly with coord_system 'chromosome'
    assert_equal(96652111, chr4_105.assembly_links_as_component('chromosome')[0].asm_start)
    assert_equal(nil, chr4_105.assembly_links_as_assembly('chromosome')[0])
    end
end

class Sequences < Test::Unit::TestCase
  def setup
    @seq_region = SeqRegion.find(92594)
  end

  def test_simple
    assert_equal('AGCTATTTTATGACTT', @seq_region.seq.slice(4,16))
  end

  def test_subseq
    assert_equal('AGCTATTTTATGACTT', @seq_region.subseq(5,20))
  end
end

class SliceProjectFromComponentToAssembly < Test::Unit::TestCase
  # |------------------------------------------> chromosome
  #     ^                 ^
  #     |                 |
  #     |-----------------> scaffold
  def test_project_from_whole_component_to_assembly
    source_slice = Slice.fetch_by_region('scaffold','Chr4.003.105')
    target_slices = source_slice.project('chromosome')

    # Start and stop of chr4_105 on Chr4
    assert_equal(96652111, target_slices[0].start)
    assert_equal(97251689, target_slices[0].stop)
  end

  # |------------------------------------------> chromosome
  #         ^        ^
  #         |        |
  #     |-----------------> scaffold
  def test_project_from_component_to_assembly_with_positions
    source_slice = Slice.fetch_by_region('scaffold','Chr4.003.105', 42, 2007)
    target_slices = source_slice.project('chromosome')

    # Position 42 on chr4_105 is position 96652152, position 2007 is 96654117
    assert_equal(96652152, target_slices[0].start)
    assert_equal(96654117, target_slices[0].stop)
  end

  # |------------------------------------------> scaffold
  #         ^        ^
  #         |        |
  #       ----------------> contig
  #      /
  #   |--
  def test_project_from_component_to_assembly_with_positions_and_cmp_start_not_1
    source_slice = Slice.fetch_by_region('contig', 'AAFC03020247', 42, 2007)
    target_slices = source_slice.project('scaffold')

    # Position 42 on AAFC03020247 is position 6570 on ChrUn.003.3522, position 2007 is 8565
    assert_equal(6570, target_slices[0].start)
    assert_equal(8535, target_slices[0].stop)
  end

  # |------------------------------------------> scaffold
  #         ^        ^
  #         |        |
  #     <-----------------| contig
  def test_project_from_component_to_assembly_with_strand
    source_slice_fw = Slice.fetch_by_region('contig', 'AAFC03020247')
    target_slices_fw = source_slice_fw.project('scaffold')

    assert_equal(1, target_slices_fw[0].strand)

    source_slice_rev = Slice.fetch_by_region('contig', 'AAFC03061502')
    target_slices_rev = source_slice_rev.project('scaffold')

    assert_equal(-1, target_slices_rev[0].strand)
  end
end

class SliceProjectFromComponentToAssemblyUsingTopLevel < Test::Unit::TestCase
  # |------------------------------------------> chromosome
  #     ^                 ^
  #     |                 |
  #     |-----------------> scaffold
  def test_project_from_whole_component_to_assembly
    source_slice = Slice.fetch_by_region('scaffold','Chr4.003.105')
    target_slices = source_slice.project('toplevel')

    # Start and stop of chr4_105 on Chr4
    assert_equal(96652111, target_slices[0].start)
    assert_equal(97251689, target_slices[0].stop)
  end

  # |------------------------------------------> chromosome
  #         ^        ^
  #         |        |
  #     |-----------------> scaffold
  def test_project_from_component_to_assembly_with_positions
    source_slice = Slice.fetch_by_region('scaffold','Chr4.003.105', 42, 2007)
    target_slices = source_slice.project('toplevel')

    # Position 42 on chr4_105 is position 96652152, position 2007 is 96654117
    assert_equal(96652152, target_slices[0].start)
    assert_equal(96654117, target_slices[0].stop)
  end
end

class SliceProjectFromAssemblyToComponentForwardStrands < Test::Unit::TestCase
  def setup
    @source_slice_single_scaffold = Slice.fetch_by_region('chromosome', '4', 96652152, 96654117)
    @target_slices_single_scaffold = @source_slice_single_scaffold.project('scaffold')

    @source_slice_two_scaffolds = Slice.fetch_by_region('chromosome','4', 96652152, 98000000)
    @target_slices_two_scaffolds = @source_slice_two_scaffolds.project('scaffold')

    @source_slice_four_scaffolds = Slice.fetch_by_region('chromosome', '4', 96652152, 99000000)
    @target_slices_four_scaffolds = @source_slice_four_scaffolds.project('scaffold')

    @source_slice_contigs_with_strand = Slice.fetch_by_region('chromosome', '4', 329500, 380000)
    @target_slices_contigs_with_strand = @source_slice_contigs_with_strand.project('contig')

    @source_slice_contigs_with_strand_ends_in_gaps = Slice.fetch_by_region('chromosome', '4', 345032, 388626)
    @target_slices_contigs_with_strand_ends_in_gaps = @source_slice_contigs_with_strand_ends_in_gaps.project('contig')
  end

  #     |-----------------> scaffold
  #         ^          ^
  #         |          |
  # |------------------------------------------> chromosome
  def test_project_from_assembly_to_single_component
    # Position 96652152 on chr4 is position 42 on scaffold, position 96654117 is 2007
    assert_equal('Chr4.003.105', @target_slices_single_scaffold[0].seq_region.name)
    assert_equal(42, @target_slices_single_scaffold[0].start)
    assert_equal(2007, @target_slices_single_scaffold[0].stop)
  end

  #     |----->   |--------> scaffold
  #         ^          ^
  #         |          |
  # |------------------------------------------> chromosome
  def test_project_from_assembly_to_two_components
    # This chromosomal region is covered by scaffolds Chr4.003.105, a gap and Chr5.003.106
    #  * Position 96652152 on chr 4 is position 42 on scaffold Chr4.105
    #  * Position 98000000 on chr 4 is position 738311 on scaffold Chr4.106
    assert_equal(3, @target_slices_two_scaffolds.length)
    assert_equal('scaffold:Btau_3.1:Chr4.003.105:42:599579:1', @target_slices_two_scaffolds[0].display_name)
    assert_equal(Gap, @target_slices_two_scaffolds[1].class)
    assert_equal('scaffold:Btau_3.1:Chr4.003.106:1:738311:1', @target_slices_two_scaffolds[2].display_name)
  end

  #     |----->   |-------->   |--->    |------->  scaffold
  #         ^                                ^
  #         |                                |
  # |--------------------------------------------------> chromosome
  def test_project_from_assembly_to_four_components
    # This chromosomal region is covered by scaffolds Chr4.003.105 and Chr5.003.106
    assert_equal(7, @target_slices_four_scaffolds.length)
    assert_equal('scaffold:Btau_3.1:Chr4.003.105:42:599579:1', @target_slices_four_scaffolds[0].display_name)
    assert_equal(Gap, @target_slices_four_scaffolds[1].class)
    assert_equal('scaffold:Btau_3.1:Chr4.003.106:1:1009889:1', @target_slices_four_scaffolds[2].display_name)
    assert_equal(Gap, @target_slices_four_scaffolds[3].class)
    assert_equal('scaffold:Btau_3.1:Chr4.003.107:1:608924:1', @target_slices_four_scaffolds[4].display_name)
    assert_equal(Gap, @target_slices_four_scaffolds[5].class)
    assert_equal('scaffold:Btau_3.1:Chr4.003.108:1:99498:1', @target_slices_four_scaffolds[6].display_name)
  end

  #     |----->   |-------->   <---|  <--|  |----->  contig
  #         ^                                 ^
  #         |                                 |
  # |--------------------------------------------------> chromosome
  def test_project_from_assembly_to_contigs_with_strand
    # This chromosomal region is covered by 5 contigs and 1 gap: CoCoCoGaCoCo
    # Two of the contigs are on the reverse strand.
    assert_equal(6, @target_slices_contigs_with_strand.length)
    assert_equal('contig::AAFC03092598:60948:61145:1', @target_slices_contigs_with_strand[0].display_name)
    assert_equal('contig::AAFC03118261:25411:37082:1', @target_slices_contigs_with_strand[1].display_name)
    assert_equal('contig::AAFC03092594:1:3622:-1', @target_slices_contigs_with_strand[2].display_name)
    assert_equal(Gap, @target_slices_contigs_with_strand[3].class)
    assert_equal('contig::AAFC03092597:820:35709:-1', @target_slices_contigs_with_strand[4].display_name)
    assert_equal('contig::AAFC03032210:13347:13415:1', @target_slices_contigs_with_strand[5].display_name)
  end

  #      <--|  |----->        contig
  #   ^                 ^
  #   |                 |
  # |--------------------------------------------------> chromosome
  def test_project_from_assembly_to_contigs_with_strand_and_ending_in_gaps
    # This chromosomal region is covered by 2 contigs and 2 gaps at the end: GaCoCoGa
    # Two of the contigs are on the reverse strand.
    assert_equal(4, @target_slices_contigs_with_strand_ends_in_gaps.length)
    assert_equal(Gap, @target_slices_contigs_with_strand_ends_in_gaps[0].class)
    assert_equal('contig::AAFC03092597:820:35709:-1', @target_slices_contigs_with_strand_ends_in_gaps[1].display_name)
    assert_equal('contig::AAFC03032210:13347:22036:1', @target_slices_contigs_with_strand_ends_in_gaps[2].display_name)
    assert_equal(Gap, @target_slices_contigs_with_strand_ends_in_gaps[3].class)
  end


end
