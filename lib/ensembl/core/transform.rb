#
# = bio/api/ensembl/core/transform.rb - transform positions for Ensembl Slice
#
# Copyright::   Copyright (C) 2007 Jan Aerts <http://jandot.myopenid.com>
# License::     The Ruby License
#
nil
module Ensembl
  nil
  module Core
    nil
    module Sliceable
      # = DESCRIPTION
      # The #transform method is used to transfer coordinates for a feature
      # from one coordinate system to another. It basically creates a clone of
      # the original feature and changes the seq_region, start position, stop
      # position and strand.
      #
      # Suppose you have a feature on a
      # contig in human (let's say on contig AC000031.6.1.38703) and you
      # want to know the coordinates on the chromosome. This is a
      # transformation of coordinates from a higher ranked coordinate system to
      # a lower ranked coordinate system. Transformations can also be done
      # from a chromosome to the contig level.
      #
      # In contrast to the #project method of Sliceables, the
      # coordinates of a feature can only transformed to the target
      # coordinate system if there is no ambiguity to which SeqRegion.
      #
      # For example, gene A can be transferred from the chromosome system to
      # the clone coordinate system, whereas gene B can not.
      #
      #       gene A                     gene B
      #  |---<=====>--------------------<=====>----------------| chromosome
      #
      #   |-----------|     |-------|  |---------|               clones
      #              |-----------| |-------|    |--------|
      #
      #   gene_a.transform('clone') --> gene
      #   gene_b.transform('clone') --> nil
      #
      # At the moment, transformations can only be done if the two coordinate
      # systems are linked directly in the 'assembly' table.
      #
      # = USAGE
      #
      #  # Get a gene in cow and transform to scaffold level
      #  # (i.e. going from a high rank coord system to a lower rank coord
      #  # system)
      #  # Cow scaffold Chr4.10 lies on Chr4 from 8030345 to 10087277 on the
      #  # reverse strand
      #  source_gene = Gene.find(2408)
      #  target_gene = source_gene.transform('scaffold')
      #  puts source_gene.seq_region.name   #--> 4
      #  puts source_gene.seq_region_start  #--> 8104409
      #  puts source_gene.seq_region_end    #--> 8496477
      #  puts source_gene.seq_region_strand #--> -1
      #  puts target_gene.seq_region.name   #--> Chr4.003.10
      #  puts target_gene.seq_region_start  #--> 1590800
      #  puts target_gene.seq_region_end    #--> 1982868
      #  puts target_gene.seq_region_strand #--> 1
      #
      # ---
      # *Arguments*:
      # * coord_system_name:: name of coordinate system to transform to
      #   coordinates to
      # *Returns*:: nil or an object of the same class as self
      def transform(coord_system_name)
        #-
        # There are two things I can do:
        # (1) just use project
        # (2) avoid doing all the calculations in project if the source slice
        #     covers multiple target slices, and _then_ go for project.
        # Let's go for nr 1 for the moment and optimize later.
        #+

        if self.slice.seq_region.coord_system.name == coord_system_name
          return self
        end

        target_slices = self.slice.project(coord_system_name)
        if target_slices.length > 1
          return nil
        else
          clone = self.clone
          clone.seq_region_id = target_slices[0].seq_region.id
          clone.seq_region_start = target_slices[0].start
          clone.seq_region_end = target_slices[0].stop

          clone.seq_region_strand = target_slices[0].strand * self.strand

          return clone
        end
      end
    end
  end
end
