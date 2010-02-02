#
# = test/unit/release_53/core/test_project.rb - Unit test for Ensembl::Core
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

class SliceProjectFromAssemblyToComponentForwardStrands < Test::Unit::TestCase
  def setup
    DBConnection.connect('bos_taurus', 56)
    @source_slice_single_contig = Slice.fetch_by_region('chromosome', '20', 175000, 180000)
    @target_slices_single_contig = @source_slice_single_contig.project('contig')

    @source_slice_two_contigs = Slice.fetch_by_region('chromosome','20', 175000, 190000)
    @target_slices_two_contigs = @source_slice_two_contigs.project('contig')

    @source_slice_contigs_with_strand = Slice.fetch_by_region('chromosome', '20', 160000, 190000)
    @target_slices_contigs_with_strand = @source_slice_contigs_with_strand.project('contig')

    @source_slice_contigs_with_strand_ends_in_gaps = Slice.fetch_by_region('chromosome', '20', 170950, 196000)
    @target_slices_contigs_with_strand_ends_in_gaps = @source_slice_contigs_with_strand_ends_in_gaps.project('contig')
  end
  
  def teardown
    DBConnection.remove_connection
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