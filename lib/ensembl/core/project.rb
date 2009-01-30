#
# = ensembl/core/project.rb - project calculations for Ensembl Slice
#
# Copyright::   Copyright (C) 2007 Jan Aerts <http://jandot.myopenid.com>
# License::     The Ruby License
#
module Ensembl
  module Core
    class Slice
      # = DESCRIPTION
      # The Slice#project method is used to transfer coordinates from one
      # coordinate system to another. Suppose you have a slice on a
      # contig in human (let's say on contig AC000031.6.1.38703) and you
      # want to know the coordinates on the chromosome. This is a
      # projection of coordinates from a higher ranked coordinate system to
      # a lower ranked coordinate system. Projections can also be done
      # from a chromosome to the contig level. However, it might be possible
      # that more than one contig has to be included and that there exist
      # gaps between the contigs. The output of this method therefore is
      # an _array_ of Slice and Gap objects.
      #
      # At the moment, projections can only be done if the two coordinate
      # systems are linked directly in the 'assembly' table.
      #
      # = USAGE
      #
      #  # Get a contig slice in cow and project to scaffold level
      #  # (i.e. going from a high rank coord system to a lower rank coord
      #  # system)
      #  source_slice = Slice.fetch_by_region('contig', 'AAFC03020247', 42, 2007)
      #  target_slices = source_slice.project('scaffold')
      #  puts target_slices.length	    #--> 1
      #  puts target_slices[0].display_name #--> scaffold:ChrUn.003.3522:6570:8535:1
      #
      #  # Get a chromosome slice in cow and project to scaffold level
      #  # (i.e. going from a low rank coord system to a higher rank coord
      #  # system)
      #  # The region 96652152..98000000 on BTA4 is covered by 2 scaffolds
      #  # that are separated by a gap.
      #  source_slice = Slice.fetch_by_region('chromosome','4', 96652152, 98000000)
      #  target_slices = source_slice.project('scaffold')
      #  puts target_slices.length	    #--> 3
      #  first_bit, second_bit, third_bit = target_slices
      #  puts first_bit.display_name	    #--> scaffold:Btau_3.1:Chr4.003.105:42:599579:1
      #  puts second_bit.class  	    #--> Gap
      #  puts third_bit.display_name	    #--> scaffold:Btau_3.1:Chr4.003.106:1:738311:1
      #
      # ---
      # *Arguments*:
      # * coord_system_name:: name of coordinate system to project
      #   coordinates to
      # *Returns*:: an array consisting of Slices and, if necessary, Gaps
      def project(coord_system_name)
        answer = Array.new # an array of slices
      	source_coord_system = self.seq_region.coord_system
        target_coord_system = nil
      	if coord_system_name == 'toplevel'
          target_coord_system = CoordSystem.find_toplevel
      	  coord_system_name = target_coord_system.name
        elsif coord_system_name == 'seqlevel'
          target_coord_system = CoordSystem.find_seqlevel
      	  coord_system_name = target_coord_system.name
        else
          target_coord_system = CoordSystem.find_by_name(coord_system_name)
        end

        if target_coord_system.rank < source_coord_system.rank
          # We're going from component to assembly, which is easy.
          assembly_links = self.seq_region.assembly_links_as_component(coord_system_name)
          
          if assembly_links.length == 0
            return []
          else
      	    assembly_links.each do |assembly_link|
              target_seq_region = assembly_link.asm_seq_region
              target_start = self.start + assembly_link.asm_start - assembly_link.cmp_start
              target_stop = self.stop + assembly_link.asm_start - assembly_link.cmp_start
              target_strand = self.strand * assembly_link.ori # 1x1=>1, 1x-1=>-1, -1x-1=>1
              
              answer.push(Slice.new(target_seq_region, target_start, target_stop, target_strand))
            end
          end
          
        else
          # If we're going from assembly to component, the answer of the target method
      	  # is an array consisting of Slices intermitted with Gaps.

          # ASSEMBLY_EXCEPTIONS
          # CAUTION: there are exceptions to the assembly (stored in the assembly_exception)
          # table which make things a little bit more difficult... For example,
          # in human, the assembly data for the pseudo-autosomal region (PAR) of
          # Y is *not* stored in the assembly table. Instead, there is a record
          # in the assembly_exception table that says: "For chr Y positions 1
          # to 2709520, use chr X:1-2709520 for the assembly data."
          # As a solution, what we'll do here, is split the assembly up in blocks:
          # if a slice covers both the PAR and the allosomal region, we'll make
          # two subslices (let's call them blocks not to intercede with the
          # Slice#subslices method) and project these independently.
          assembly_exceptions = AssemblyException.find_all_by_seq_region_id(self.seq_region.id)
          if assembly_exceptions.length > 0
            # Check if this bit of the original slice is covered in the
            # assembly_exception table.
            overlapping_exceptions = Array.new
            assembly_exceptions.each do |ae|
              if Slice.new(self.seq_region, ae.seq_region_start, ae.seq_region_end).overlaps?(self)
                if ae.exc_type == 'HAP'
                  raise NotImplementedError, "The haplotype exceptions are not implemented (yet). You can't project this slice."
                end
                overlapping_exceptions.push(ae)
              end
            end

            if overlapping_exceptions.length > 0
              # First get all assembly blocks from chromosome Y
              source_assembly_blocks = self.excise(overlapping_exceptions.collect{|e| e.seq_region_start .. e.seq_region_end})
              # And insert the blocks of chromosome X
              all_assembly_blocks = Array.new #both for chr X and Y
              # First do all exceptions between the first and last block
              previous_block = nil
              source_assembly_blocks.sort_by{|b| b.start}.each do |b|
                if previous_block.nil?
                  all_assembly_blocks.push(b)
                  previous_block = b
                  next
                end
                # Find the exception record
                exception = nil
                assembly_exceptions.each do |ae|
                  if ae.seq_region_end == b.start - 1
                    exception = ae
                    break
                  end
                end

                new_slice_start = exception.exc_seq_region_start + ( previous_block.stop - exception.seq_region_start )
                new_slice_stop = exception.exc_seq_region_start + ( b.start - exception.seq_region_start )
                new_slice_strand = self.strand * exception.ori
                new_slice = Slice.fetch_by_region(self.seq_region.coord_system.name, SeqRegion.find(exception.exc_seq_region_id).name, new_slice_start, new_slice_stop, new_slice_strand)

                all_assembly_blocks.push(new_slice)
                all_assembly_blocks.push(b)
                previous_block = b
              end

              # And then see if we have to add an additional one at the start or end
              first_block = source_assembly_blocks.sort_by{|b| b.start}[0]
              if first_block.start > self.start
                exception = assembly_exceptions.sort_by{|ae| ae.seq_region_start}[0]
                new_slice_start = exception.exc_seq_region_start + ( self.start - exception.seq_region_start )
                new_slice_stop = exception.exc_seq_region_start + ( first_block.start - 1 - exception.seq_region_start )
                new_slice_strand = self.strand * exception.ori
                new_slice = Slice.fetch_by_region(self.seq_region.coord_system.name, SeqRegion.find(exception.exc_seq_region_id).name, new_slice_start, new_slice_stop, new_slice_strand)

                all_assembly_blocks.unshift(new_slice)
              end

              last_block = source_assembly_blocks.sort_by{|b| b.start}[-1]
              if last_block.stop < self.stop
                exception = assembly_exceptions.sort_by{|ae| ae.seq_region_start}[-1]
                new_slice_start = exception.exc_seq_region_start + ( last_block.stop + 1 - exception.seq_region_start )
                new_slice_stop = exception.exc_seq_region_start + ( self.stop - exception.seq_region_start )
                new_slice_strand = self.strand * exception.ori
                new_slice = Slice.fetch_by_region(self.seq_region.coord_system.name, SeqRegion.find(exception.exc_seq_region_id).name, new_slice_start, new_slice_stop, new_slice_strand)

                all_assembly_blocks.shift(new_slice)
              end

              answer = Array.new
              all_assembly_blocks.each do |b|
                answer.push(b.project(coord_system_name))
              end
              answer.flatten!

              return answer
            end

          end
          # END OF ASSEMBLY_EXCEPTIONS

          # Get all AssemblyLinks starting from this assembly and for which
      	  # the cmp_seq_region.coord_system is what we want.
      	  assembly_links = self.seq_region.assembly_links_as_assembly(coord_system_name)

          # Now reject all the components that lie _before_ the source, then
      	  # reject all the components that lie _after_ the source.
          # Then sort based on their positions.
      	  sorted_overlapping_assembly_links = assembly_links.reject{|al| al.asm_end < self.start}.reject{|al| al.asm_start > self.stop}.sort_by{|al| al.asm_start}
          if sorted_overlapping_assembly_links.length == 0
            return []
          end

          # What we'll do, is create slices for all the underlying components,
          # including the first and the last one. At first, the first and last
          # components are added in their entirity and will only be cropped afterwards.
      	  previous_stop = nil
          sorted_overlapping_assembly_links.each_index do |i|
            this_link = sorted_overlapping_assembly_links[i]
      	    if i == 0
              answer.push(Slice.new(this_link.cmp_seq_region, this_link.cmp_start, this_link.cmp_end, this_link.ori))
            	next
            end
            previous_link = sorted_overlapping_assembly_links[i-1]

            # If there is a gap with the previous link: add a gap
      	    if this_link.asm_start > ( previous_link.asm_end + 1 )
              gap_size = this_link.asm_start - previous_link.asm_end - 1
              answer.push(Gap.new(CoordSystem.find_by_name(coord_system_name), gap_size))
            end

            # And add the component itself as a Slice
      	    answer.push(Slice.new(this_link.cmp_seq_region, this_link.cmp_start, this_link.cmp_end, this_link.ori))
          end

          # Now see if we have to crop the first and/or last slice
          first_link = sorted_overlapping_assembly_links[0]
          if self.start > first_link.asm_start
            if first_link.ori == -1
              answer[0].stop = first_link.cmp_start + ( first_link.asm_end - self.start )
            else
              answer[0].start = first_link.cmp_start + ( self.start - first_link.asm_start )
            end
          end

          last_link = sorted_overlapping_assembly_links[-1]
          if self.stop < last_link.asm_end
            if last_link.ori == -1
              answer[-1].start = last_link.cmp_start + ( last_link.asm_end - self.stop)
            else
              answer[-1].stop = last_link.cmp_start + ( self.stop - last_link.asm_start )
            end
          end

          # And check if we have to add Ns at the front and/or back
          if self.start < first_link.asm_start
            gap_size = first_link.asm_start - self.start
            answer.unshift(Gap.new(CoordSystem.find_by_name(coord_system_name), gap_size))
          end
          if self.stop > last_link.asm_end
            gap_size = self.stop - last_link.asm_end
            answer.push(Gap.new(CoordSystem.find_by_name(coord_system_name), gap_size))
          end
        end
        return answer

      end
    end
  end
end
