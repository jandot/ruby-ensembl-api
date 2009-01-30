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

DBConnection.connect('bos_taurus', 50)

class CoordinateMappingsTestSimple < Test::Unit::TestCase
  # First see if the relationships work
  def test_assemblies
    # Contig AAFC03055291 should only be a component of chromosome 20
    contig_coord_system = CoordSystem.find_by_name('contig')
    aafc03055291 = SeqRegion.find_by_name_and_coord_system_id('AAFC03055291', contig_coord_system.id)
    assert_equal(1, aafc03055291.assembled_seq_regions.length)

    # Chromosome 20 has 2970 components
    chr_coord_system = CoordSystem.find_by_name('chromosome')
    chr20 = SeqRegion.find_by_name_and_coord_system_id('20', chr_coord_system.id)
    assert_equal(2970, chr20.component_seq_regions.length)

    # Chromosome 20 has 2970 contigs
    assert_equal(2970, chr20.component_seq_regions('contig').length)

    # Positions of the link between Chr20 and AAFC03055291
    # * Contig AAFC03055291 starts at position 13970982 on chromosome Chr20
    assert_equal(13970982, aafc03055291.assembly_links_as_component('chromosome')[0].asm_start)
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

#class SliceProjectFromComponentToAssembly < Test::Unit::TestCase
#  # |------------------------------------------> chromosome
#  #     ^                 ^
#  #     |                 |
#  #     |-----------------> scaffold
#  def test_project_from_whole_component_to_assembly
#    source_slice = Slice.fetch_by_region('contig','AAFC03055291')
#    target_slices = source_slice.project('chromosome')
#
#    # Start and stop of chr4_105 on Chr4
#    assert_equal(13970982, target_slices[0].start)
#    assert_equal(13982069, target_slices[0].stop)
#  end
#
#  # |------------------------------------------> chromosome
#  #         ^        ^
#  #         |        |
#  #     |-----------------> scaffold
#  def test_project_from_component_to_assembly_with_positions
#    source_slice = Slice.fetch_by_region('scaffold','Chr4.003.105', 42, 2007)
#    target_slices = source_slice.project('chromosome')
#
#    # Position 42 on chr4_105 is position 96652152, position 2007 is 96654117
#    assert_equal(96652152, target_slices[0].start)
#    assert_equal(96654117, target_slices[0].stop)
#  end
#
#  # |------------------------------------------> scaffold
#  #         ^        ^
#  #         |        |
#  #       ----------------> contig
#  #      /
#  #   |--
#  def test_project_from_component_to_assembly_with_positions_and_cmp_start_not_1
#    source_slice = Slice.fetch_by_region('contig', 'AAFC03020247', 42, 2007)
#    target_slices = source_slice.project('scaffold')
#
#    # Position 42 on AAFC03020247 is position 6570 on ChrUn.003.3522, position 2007 is 8565
#    assert_equal(6570, target_slices[0].start)
#    assert_equal(8535, target_slices[0].stop)
#  end
#
#  # |------------------------------------------> scaffold
#  #         ^        ^
#  #         |        |
#  #     <-----------------| contig
#  def test_project_from_component_to_assembly_with_strand
#    source_slice_fw = Slice.fetch_by_region('contig', 'AAFC03020247')
#    target_slices_fw = source_slice_fw.project('scaffold')
#
#    assert_equal(1, target_slices_fw[0].strand)
#
#    source_slice_rev = Slice.fetch_by_region('contig', 'AAFC03061502')
#    target_slices_rev = source_slice_rev.project('scaffold')
#
#    assert_equal(-1, target_slices_rev[0].strand)
#  end
#end

#class SliceProjectFromComponentToAssemblyUsingTopLevel < Test::Unit::TestCase
#  # |------------------------------------------> chromosome
#  #     ^                 ^
#  #     |                 |
#  #     |-----------------> scaffold
#  def test_project_from_whole_component_to_assembly
#    source_slice = Slice.fetch_by_region('scaffold','Chr4.003.105')
#    target_slices = source_slice.project('toplevel')
#
#    # Start and stop of chr4_105 on Chr4
#    assert_equal(96652111, target_slices[0].start)
#    assert_equal(97251689, target_slices[0].stop)
#  end
#
#  # |------------------------------------------> chromosome
#  #         ^        ^
#  #         |        |
#  #     |-----------------> scaffold
#  def test_project_from_component_to_assembly_with_positions
#    source_slice = Slice.fetch_by_region('scaffold','Chr4.003.105', 42, 2007)
#    target_slices = source_slice.project('toplevel')
#
#    # Position 42 on chr4_105 is position 96652152, position 2007 is 96654117
#    assert_equal(96652152, target_slices[0].start)
#    assert_equal(96654117, target_slices[0].stop)
#  end
#end

class SliceProjectFromAssemblyToComponentForwardStrands < Test::Unit::TestCase
  def setup
    @source_slice_single_contig = Slice.fetch_by_region('chromosome', '20', 175000, 180000)
    @target_slices_single_contig = @source_slice_single_contig.project('contig')

    @source_slice_two_contigs = Slice.fetch_by_region('chromosome','20', 175000, 190000)
    @target_slices_two_contigs = @source_slice_two_contigs.project('contig')

    @source_slice_contigs_with_strand = Slice.fetch_by_region('chromosome', '20', 160000, 190000)
    @target_slices_contigs_with_strand = @source_slice_contigs_with_strand.project('contig')

    @source_slice_contigs_with_strand_ends_in_gaps = Slice.fetch_by_region('chromosome', '20', 170950, 196000)
    @target_slices_contigs_with_strand_ends_in_gaps = @source_slice_contigs_with_strand_ends_in_gaps.project('contig')
  end

  #     |-----------------> contig
  #         ^          ^
  #         |          |
  # |------------------------------------------> chromosome
  def test_project_from_assembly_to_single_component
    # Position 175000 on chr20 is position 4030 on contig, position 180000 is 9030
    assert_equal('AAFC03028970', @target_slices_single_contig[0].seq_region.name)
    assert_equal(4030, @target_slices_single_contig[0].start)
    assert_equal(9030, @target_slices_single_contig[0].stop)
  end

  #     |----->   |--------> contig
  #         ^          ^
  #         |          |
  # |------------------------------------------> chromosome
  def test_project_from_assembly_to_two_components
    # This chromosomal region is covered by contigs AAFC03028970, a gap and AAFC03028962
    #  * Position 175000 on chr 20 is position 4030 on contig AAFC03028970
    #  * Position 190000 on chr 20 is position 35 on contig AAFC03028962
    assert_equal(3, @target_slices_two_contigs.length)
    assert_equal('contig:Btau_4.0:AAFC03028970:4030:17365:1', @target_slices_two_contigs[0].display_name)
    assert_equal(Gap, @target_slices_two_contigs[1].class)
    assert_equal('contig:Btau_4.0:AAFC03028962:1:35:1', @target_slices_two_contigs[2].display_name)
  end

  #     |----->   <-------|   |------->  |------->  contig
  #         ^                                 ^
  #         |                                 |
  # |--------------------------------------------------> chromosome
  def test_project_from_assembly_to_contigs_with_strand
    # This chromosomal region is covered by 4 contigs and 3 gaps
    # One of the contigs are on the reverse strand.
    assert_equal(7, @target_slices_contigs_with_strand.length)
    assert_equal('contig:Btau_4.0:AAFC03028964:90:9214:1', @target_slices_contigs_with_strand[0].display_name)
    assert_equal(Gap, @target_slices_contigs_with_strand[1].class)
    assert_equal('contig:Btau_4.0:AAFC03028959:1:1746:-1', @target_slices_contigs_with_strand[2].display_name)
    assert_equal(Gap, @target_slices_contigs_with_strand[3].class)
    assert_equal('contig:Btau_4.0:AAFC03028970:1:17365:1', @target_slices_contigs_with_strand[4].display_name)
    assert_equal(Gap, @target_slices_contigs_with_strand[5].class)
    assert_equal('contig:Btau_4.0:AAFC03028962:1:35:1', @target_slices_contigs_with_strand[6].display_name)
  end

  #      <--|  |----->        contig
  #   ^                 ^
  #   |                 |
  # |--------------------------------------------------> chromosome
  def test_project_from_assembly_to_contigs_with_strand_and_ending_in_gaps
    # This chromosomal region is covered by 2 contigs and 2 gaps at the end: GaCoGaCoGa
    assert_equal(5, @target_slices_contigs_with_strand_ends_in_gaps.length)
    assert_equal(Gap, @target_slices_contigs_with_strand_ends_in_gaps[0].class)
    assert_equal('contig:Btau_4.0:AAFC03028970:1:17365:1', @target_slices_contigs_with_strand_ends_in_gaps[1].display_name)
    assert_equal(Gap, @target_slices_contigs_with_strand_ends_in_gaps[2].class)
    assert_equal('contig:Btau_4.0:AAFC03028962:1:5704:1', @target_slices_contigs_with_strand_ends_in_gaps[3].display_name)
    assert_equal(Gap, @target_slices_contigs_with_strand_ends_in_gaps[4].class)
  end


end
