#
# = ensembl/core/slice.rb - Slice object for Ensembl core
#
# Copyright::   Copyright (C) 2007 Jan Aerts <http://jandot.myopenid.com>
# License::     The Ruby License
#
nil
module Ensembl
  nil
  module Core
    # = DESCRIPTION
    # From the perl API tutorial
    # (http://www.ensembl.org/info/software/core/core_tutorial.html): "A
    # Slice object represents a continuous region of a genome. Slices can be
    # used to obtain sequence, features or other information from a
    # particular region of interest."
    #
    # In contrast to almost all other classes of Ensembl::Core,
    # the Slice class is not based on ActiveRecord.
    #
    # = USAGE
    #  chr4 = SeqRegion.find_by_name('4')
    #  my_slice = Slice.new(chr4, 95000, 98000, -1)
    #  puts my_slice.display_name    #--> 'chromosome:4:Btau_3.1:95000:98000:1'
    class Slice
      attr_accessor :seq_region, :start, :stop, :strand, :seq

      #################
      ## CREATE A SLICE
      #################

      # = DESCRIPTION
      # Create a new Slice object from scratch.
      #
      # = USAGE
      #  chr4 = SeqRegion.find_by_name('4')
      #  my_slice = Slice.new(chr4, 95000, 98000, -1)
      # ---
      # *Arguments*:
      # * seq_region: SeqRegion object
      # * start: start position of the Slice on the SeqRegion (default = 1)
      # * stop: stop position of the Slice on the SeqRegion (default: end of
      #   SeqRegion)
      # * strand: strand of the Slice relative to the SeqRegion (default = 1)
      # *Returns*:: Slice object
      def initialize(seq_region, start = 1, stop = seq_region.length, strand = 1)
        if start.nil?
          start = 1
        end
      	if stop.nil?
          stop = seq_region.length
        end
      	unless seq_region.class == Ensembl::Core::SeqRegion
          raise 'First argument has to be a Ensembl::Core::SeqRegion object'
        end
      	@seq_region, @start, @stop, @strand = seq_region, start, stop, strand
        @seq = nil
      end

      # = DESCRIPTION
      # Create a Slice without first creating the SeqRegion object.
      #
      # = USAGE
      #  my_slice_1 = Slice.fetch_by_region('chromosome','4',95000,98000,1)
      #
      # ---
      # *Arguments*:
      # * coord_system: name of CoordSystem (required)
      # * seq_region: name of SeqRegion (required)
      # * start: start of Slice on SeqRegion (default = 1)
      # * stop: stop of Slice on SeqRegion (default = end of SeqRegion)
      # * strand: strand of Slice on SeqRegion
      # *Returns*:: Ensembl::Core::Slice object
      def self.fetch_by_region(coord_system_name, seq_region_name, start = nil, stop = nil, strand = 1, version = nil)
        all_coord_systems = Ensembl::Core::CoordSystem.find_all_by_name(coord_system_name)
      	coord_system = nil
        if version.nil? # Take the version with the lowest rank
          coord_system = all_coord_systems.sort_by{|cs| cs.version}.reverse.shift
        else
          coord_system = all_coord_systems.select{|cs| cs.version == version}[0]
        end
      	unless coord_system.class == Ensembl::Core::CoordSystem
          message = "Couldn't find a Ensembl::Core::CoordSystem object with name '" + coord_system_name + "'"
      	  if ! version.nil?
            message += " and version '" + version + "'"
          end
      	  raise message
        end

        seq_region = Ensembl::Core::SeqRegion.find_by_name_and_coord_system_id(seq_region_name, coord_system.id)
        #seq_region = Ensembl::Core::SeqRegion.find_by_sql("SELECT * FROM seq_region WHERE name = '" + seq_region_name + "' AND coord_system_id = " + coord_system.id.to_s)[0]
      	unless seq_region.class == Ensembl::Core::SeqRegion
          raise "Couldn't find a Ensembl::Core::SeqRegion object with the name '" + seq_region_name + "'"
        end

        return Ensembl::Core::Slice.new(seq_region, start, stop, strand)
      end

      # = DESCRIPTION
      # Create a Slice based on a Gene
      #
      # = USAGE
      #  my_slice = Slice.fetch_by_gene_stable_id('ENSG00000184895')
      #
      # ---
      # *Arguments*:
      # * gene_stable_id: Ensembl gene stable_id (required)
      # *Returns*:: Ensembl::Core::Slice object
      def self.fetch_by_gene_stable_id(gene_stable_id, flanking_seq_length = 0)
        gene_stable_id = Ensembl::Core::GeneStableId.find_by_stable_id(gene_stable_id)
      	gene = gene_stable_id.gene
        seq_region = gene.seq_region

        return Ensembl::Core::Slice.new(seq_region, gene.seq_region_start - flanking_seq_length, gene.seq_region_end + flanking_seq_length, gene.seq_region_strand)
      end

      # = DESCRIPTION
      # Create a Slice based on a Transcript
      #
      # = USAGE
      #  my_slice = Slice.fetch_by_transcript_stable_id('ENST00000383673')
      #
      # ---
      # *Arguments*:
      # * transcript_stable_id: Ensembl transcript stable_id (required)
      # *Returns*:: Ensembl::Core::Slice object
      def self.fetch_by_transcript_stable_id(transcript_stable_id, flanking_seq_length = 0)
        transcript_stable_id = Ensembl::Core::TranscriptStableId.find_by_stable_id(transcript_stable_id)
      	transcript = transcript_stable_id.transcript
        seq_region = transcript.seq_region

        return Ensembl::Core::Slice.new(seq_region, transcript.seq_region_start - flanking_seq_length, transcript.seq_region_end + flanking_seq_length, transcript.seq_region_strand)
      end

      # = DESCRIPTION
      # Create an array of all Slices for a given coordinate system.
      #
      # = USAGE
      #  slices = Slice.fetch_all('chromosome')
      #
      # ---
      # *Arguments*:
      # * coord_system_name:: name of coordinate system (default = chromosome)
      # * coord_system_version:: version of coordinate system (default = nil)
      # *Returns*:: an array of Ensembl::Core::Slice objects
      def self.fetch_all(coord_system_name = 'chromosome', version = nil)
        answer = Array.new
      	if version.nil?
          coord_system = Ensembl::Core::CoordSystem.find_by_name(coord_system_name)
        else
          coord_system = Ensembl::Core::CoordSystem.find_by_name_and_version(coord_system_name, version)
        end

      	coord_system.seq_regions.each do |seq_region|
      	  answer.push(Ensembl::Core::Slice.new(seq_region))
      	end

        return answer
      end

      ##################
      ## GENERAL METHODS
      ##################

      # = DESCRIPTION
      # Get the length of a slice
      #
      # = USAGE
      #  chr4 = SeqRegion.find_by_name('4')
      #  my_slice = Slice.new(chr4, 95000, 98000, -1)
      #  puts my_slice.length
      # ---
      # *Arguments*:: none
      # *Returns*:: Integer
      def length
        return self.stop - self.start + 1
      end

      # = DESCRIPTION
      # The display_name method returns a full name of this slice, containing
      # the name of the coordinate system, the sequence region, start and
      # stop positions on that sequence region and the strand. E.g. for a slice
      # of bovine chromosome 4 from position 95000 to 98000 on the reverse strand,
      # the display_name would look like: chromosome:4:Btau_3.1:95000:98000:-1
      #
      # = USAGE
      #  puts my_slice.display_name
      # ---
      # *Arguments*:: none
      # *Result*:: String
      def display_name
      	return [self.seq_region.coord_system.name, self.seq_region.coord_system.version, self.seq_region.name, self.start.to_s, self.stop.to_s, self.strand.to_s].join(':')
      end
      alias to_s display_name

      # = DESCRIPTION
      # The Slice#overlaps? method checks if this slice overlaps another one.
      # The other slice has to be on the same coordinate system
      #
      # = USAGE
      #  slice_a = Slice.fetch_by_region('chromosome','X',1,1000)
      #  slice_b = Slice.fetch_by_region('chromosome','X',900,1500)
      #  if slice_a.overlaps?(slice_b)
      #    puts "There slices overlap"
      #  end
      # ---
      # *Arguments*:: another slice
      # *Returns*:: true or false
      def overlaps?(other_slice)
        if ! other_slice.class == Slice
          raise RuntimeError, "The Slice#overlaps? method takes a Slice object as its arguments."
        end
        if self.seq_region.coord_system != other_slice.seq_region.coord_system
          raise RuntimeError, "The argument slice of Slice#overlaps? has to be in the same coordinate system, but were " + self.seq_region.coord_system.name + " and " + other_slice.seq_region.coord_system.name
        end

        self_range = self.start .. self.stop
        other_range = other_slice.start .. other_slice.stop

        if self_range.include?(other_slice.start) or other_range.include?(self.start)
          return true
        else
          return false
        end
      end

      # = DESCRIPTION
      # The Slice#within? method checks if this slice is contained withing another one.
      # The other slice has to be on the same coordinate system
      #
      # = USAGE
      #  slice_a = Slice.fetch_by_region('chromosome','X',1,1000)
      #  slice_b = Slice.fetch_by_region('chromosome','X',900,950)
      #  if slice_b.overlaps?(slice_a)
      #    puts "Slice b is within slice a"
      #  end
      # ---
      # *Arguments*:: another slice
      # *Returns*:: true or false
      def within?(other_slice)
        if ! other_slice.class == Slice
          raise RuntimeError, "The Slice#overlaps? method takes a Slice object as its arguments."
        end
        if self.seq_region.coord_system != other_slice.seq_region.coord_system
          raise RuntimeError, "The argument slice of Slice#overlaps? has to be in the same coordinate system, but were " + self.seq_region.coord_system.name + " and " + other_slice.seq_region.coord_system.name
        end

        self_range = self.start .. self.stop
        other_range = other_slice.start .. other_slice.stop

        if other_range.include?(self.start) and other_range.include?(self.stop)
          return true
        else
          return false
        end
      end

      # = DESCRIPTION
      # The Slice#excise method removes a bit of a slice and returns the 
      # remainder as separate slices.
      #
      # = USAGE
      #  original_slice = Slice.fetch_by_region('chromosome','X',1,10000)
      #  new_slices = original_slice.excise([500..750, 1050..1075])
      #  new_slices.each do |s|
      #    puts s.display_name
      #  end
      #
      #  # result:
      #  #   chromosome:X:1:499:1
      #  #   chromosome:X:751:1049:1
      #  #   chromosome:X:1076:10000:1
      # ---
      # *Arguments*:
      # * ranges: array of ranges (required)
      # *Returns*:: array of Slice objects
      def excise(ranges)
        if ranges.class != Array
          raise RuntimeError, "Argument should be an array of ranges"
        end
        ranges.each do |r|
          if r.class != Range
            raise RuntimeError, "Argument should be an array of ranges"
          end
        end

        answer = Array.new
        previous_excised_stop = self.start - 1
        ranges.sort_by{|r| r.first}.each do |r|
          subslice_start = previous_excised_stop + 1
          if subslice_start <= r.first - 1
            answer.push(Slice.new(self.seq_region, subslice_start, r.first - 1))
          end
          previous_excised_stop = r.last
          if r.last > self.stop
            return answer
          end
        end
        subslice_start = previous_excised_stop + 1
        answer.push(Slice.new(self.seq_region, subslice_start, self.stop))
        return answer
      end

      # = DESCRIPTION
      # Get the sequence of the Slice as a Bio::Sequence::NA object.
      #
      # If the Slice is on a CoordSystem that is not seq_level, it will try
      # to project it coordinates to the CoordSystem that does. At this
      # moment, this is only done if there is a direct link between the
      # two coordinate systems. (The perl API allows for following an
      # indirect link as well.)
      #
      # Caution: Bio::Sequence::NA makes the sequence
      # downcase!!
      #
      # = USAGE
      #  my_slice.seq.seq.to_s
      #
      # ---
      # *Arguments*:: none
      # *Returns*:: Bio::Sequence::NA object
      def seq
      	# If we already accessed the sequence, we can just
      	# call the instance variable. Otherwise, we'll have
        # to get the sequence first and create a Bio::Sequence::NA
      	# object.
        if @seq.nil?
          # First check if the slice is on the seqlevel coordinate
      	  # system, otherwise project coordinates.
          if self.seq_region.coord_system.seqlevel?
            @seq = Bio::Sequence::NA.new(self.seq_region.subseq(self.start, self.stop))
          else # we have to project coordinates
            seq_string = String.new
      	    @target_slices = self.project('seqlevel')

            @target_slices.each do |component|
              if component.class == Slice
                seq_string += component.seq # This fetches the seq recursively (see 10 lines up)
              else # it's a Gap
                seq_string += 'N' * (component.length)
              end

            end
      	    @seq = Bio::Sequence::NA.new(seq_string)

          end

          if self.strand == -1
      	    @seq.reverse_complement!
          end

        end
      	return @seq

      end

      def repeatmasked_seq
        raise NotImplementedError
      end

      # = DESCRIPTION
      # Take a sub_slice from an existing one.
      #
      # = USAGE
      #  my_sub_slice = my_slice.sub_slice(400,500)
      #
      # ---
      # *Arguments*:
      # * start: start of subslice relative to slice (default: start of slice)
      # * stop: stop of subslice relative to slice (default: stop of slice)
      # *Returns*:: Ensembl::Core::Slice object
      def sub_slice(start = self.start, stop = self.stop)
      	return self.class.new(self.seq_region, start, stop, self.strand)
      end

      # = DESCRIPTION
      # Creates overlapping subslices for a given Slice.
      #
      # = USAGE
      #  my_slice.split(50000, 250).each do |sub_slice|
      #    puts sub_slice.display_name
      #  end
      #
      # ---
      # *Arguments*:
      # * max_size: maximal size of subslices (default: 100000)
      # * overlap: overlap in bp between consecutive subslices (default: 0)
      # *Returns*:: array of Ensembl::Core::Slice objects
      def split(max_size = 100000, overlap = 0)
      	sub_slices = Array.new
        i = 0
      	self.start.step(self.length, max_size - overlap - 1) do |i|
          sub_slices.push(self.sub_slice(i, i + max_size - 1))
        end
      	i -= (overlap + 1)
        sub_slices.push(self.sub_slice(i + max_size))
      	return sub_slices
      end

      ############################
      ## GET ELEMENTS WITHIN SLICE
      ############################

      #--
      # As there should be 'getters' for a lot of classes, we'll implement
      # this with method_missing. For some of the original methods, see the end
      # of this file.
      # 
      # The optional argument is either 'true' or 'false' (default = false).
      # False if the features have to be completely contained within the slice;
      # true if just a partly overlap is sufficient.
      #++
      # Don't use this method yourself.
      def method_missing(method_name, *args)
        table_name = method_name.to_s.singularize
        class_name = table_name.camelcase

        # Convert to the class object
        target_class = nil
        ObjectSpace.each_object(Class) do |o|
          if o.name =~ /^Ensembl::Core::#{class_name}$/
            target_class = o
          end
        end

        # If it exists, see if it implements Sliceable
        if ! target_class.nil? and target_class.include?(Sliceable)
          inclusive = false
          if [TrueClass, FalseClass].include?(args[0].class)
            inclusive = args[0]
          end
          return self.get_objects(target_class, table_name, inclusive)
        end

        raise NoMethodError

      end

      # Don't use this method yourself.
      def get_objects(target_class, table_name, inclusive = false)
        answer = Array.new

        
        # Get all the coord_systems with this type of features on them
        coord_system_ids_with_features = MetaCoord.find_all_by_table_name(table_name).collect{|mc| mc.coord_system_id}

        # Get the features of the original slice
        if coord_system_ids_with_features.include?(self.seq_region.coord_system_id)
          sql = ''
          if inclusive
            sql = <<SQL
SELECT * FROM #{table_name}
WHERE seq_region_id = #{self.seq_region.id.to_s}
AND (( seq_region_start BETWEEN #{self.start.to_s} AND #{self.stop.to_s} )
OR   ( seq_region_end BETWEEN #{self.start.to_s} AND #{self.stop.to_s} )
OR   ( seq_region_start <= #{self.start.to_s} AND seq_region_end >= #{self.stop.to_s} )
    )
SQL
          else
            sql = <<SQL
SELECT * FROM #{table_name}
WHERE seq_region_id = #{self.seq_region.id.to_s}
AND seq_region_start >= #{self.start.to_s}
AND seq_region_end <= #{self.stop.to_s}   
SQL
          end
          answer.push(target_class.find_by_sql(sql))
          coord_system_ids_with_features.delete(self.seq_region.coord_system_id)
        end

        # Transform the original slice to other coord systems and get those
        # features as well. At the moment, only 'direct' projections can be made.
        # Later, I'm hoping to add functionality for following a path from one
        # coord_system to another if they're not directly linked in the assembly
        # table.
        coord_system_ids_with_features.each do |target_coord_system_id|
          target_slices = self.project(CoordSystem.find(target_coord_system_id).name)
          target_slices.each do |slice|
            if slice.class == Slice
              if inclusive
                sql = <<SQL
SELECT * FROM #{table_name}
WHERE seq_region_id = #{slice.seq_region.id.to_s}
AND (( seq_region_start BETWEEN #{slice.start.to_s} AND #{slice.stop.to_s} )
OR   ( seq_region_end BETWEEN #{slice.start.to_s} AND #{slice.stop.to_s} )
OR   ( seq_region_start <= #{slice.start.to_s} AND seq_region_end >= #{slice.stop.to_s} )
    )
SQL
              else
                sql = <<SQL
SELECT * FROM #{table_name}
WHERE seq_region_id = #{slice.seq_region.id.to_s}
AND seq_region_start >= #{slice.start.to_s}
AND seq_region_end <= #{slice.stop.to_s}   
SQL
              end 
                answer.push(target_class.find_by_sql(sql))
            end
          end
        end

        answer.flatten!
        answer.uniq!

        return answer
      end


      # = DESCRIPTION
      # Get all MiscFeatures that are located on a Slice for a given MiscSet.
      #
      # Pitfall: just looks at the CoordSystem that the Slice is located on.
      # For example, if a Slice is located on a SeqRegion on the 'chromosome'
      # CoordSystem, but all misc_features are annotated on SeqRegions of
      # the 'scaffold' CoordSystem, this method will return an empty array.
      #
      # = USAGE
      #  my_slice.misc_features('encode').each do |feature|
      #    puts feature.to_yaml
      #  end
      # ---
      # *Arguments*:
      # * code: code of MiscSet
      # *Returns*:: array of MiscFeature objects
      def misc_features(code)
      	answer = Array.new
        if code.nil?
          self.seq_region.misc_features.each do |mf|
            if mf.seq_region_start > self.start and mf.seq_region_end < self.stop
              answer.push(mf)
            end
          end
        else
          self.seq_region.misc_features.each do |mf|
            if mf.misc_sets[0].code == code
              if mf.seq_region_start > self.start and mf.seq_region_end < self.stop
                answer.push(mf)
              end
            end
          end
        end
      	return answer
      end

      # = DESCRIPTION
      # Get all DnaAlignFeatures that are located on a Slice for a given Analysis.
      #
      # Pitfall: just looks at the CoordSystem that the Slice is located on.
      # For example, if a Slice is located on a SeqRegion on the 'chromosome'
      # CoordSystem, but all dna_align_features are annotated on SeqRegions of
      # the 'scaffold' CoordSystem, this method will return an empty array.
      #
      # = USAGE
      #  my_slice.dna_align_features('Vertrna').each do |feature|
      #    puts feature.to_yaml
      #  end
      # ---
      # *Arguments*:
      # * code: name of analysis
      # *Returns*:: array of DnaAlignFeature objects
      def dna_align_features(analysis_name = nil)
      	if analysis_name.nil?
          return DnaAlignFeature.find_by_sql('SELECT * FROM dna_align_feature WHERE seq_region_id = ' + self.seq_region.id.to_s + ' AND seq_region_start >= ' + self.start.to_s + ' AND seq_region_end <= ' + self.stop.to_s)
        else
          analysis = Analysis.find_by_logic_name(analysis_name)
          return DnaAlignFeature.find_by_sql('SELECT * FROM dna_align_feature WHERE seq_region_id = ' + self.seq_region.id.to_s + ' AND seq_region_start >= ' + self.start.to_s + ' AND seq_region_end <= ' + self.stop.to_s + ' AND analysis_id = ' + analysis.id.to_s)
        end
      end

      # = DESCRIPTION
      # Get all ProteinAlignFeatures that are located on a Slice for a given Analysis.
      #
      # Pitfall: just looks at the CoordSystem that the Slice is located on.
      # For example, if a Slice is located on a SeqRegion on the 'chromosome'
      # CoordSystem, but all protein_align_features are annotated on SeqRegions of
      # the 'scaffold' CoordSystem, this method will return an empty array.
      #
      # = USAGE
      #  my_slice.protein_align_features('Uniprot').each do |feature|
      #    puts feature.to_yaml
      #  end
      # ---
      # *Arguments*:
      # * code: name of analysis
      # *Returns*:: array of ProteinAlignFeature objects
      def protein_align_features(analysis_name)
      	if analysis_name.nil?
          return ProteinAlignFeature.find_by_sql('SELECT * FROM protein_align_feature WHERE seq_region_id = ' + self.seq_region.id.to_s + ' AND seq_region_start >= ' + self.start.to_s + ' AND seq_region_end <= ' + self.stop.to_s)
        else
          analysis = Analysis.find_by_logic_name(analysis_name)
          return ProteinAlignFeature.find_by_sql('SELECT * FROM protein_align_feature WHERE seq_region_id = ' + self.seq_region.id.to_s + ' AND seq_region_start >= ' + self.start.to_s + ' AND seq_region_end <= ' + self.stop.to_s + ' AND analysis_id = ' + analysis.id.to_s)
        end
      end
    end #Slice


    # = DESCRIPTION
    # The Gap class is similar to the Slice object, but describes a gap and
    # therefore can easily be described by coordinate system and size.
    #
    class Gap
      attr_accessor :coord_system, :size

      # = DESCRIPTION
      # Create a new Gap object from scratch.
      #
      # = USAGE
      #  my_coord_system = CoordSystem.find_by_name('chromosome')
      #  # Create a gap of 10kb.
      #  gap = Gap.new(my_coord_system, 10000)
      # ---
      # *Arguments*:
      # * coord_system: CoordSystem object (required)
      # * length: length of the gap (required)
      # *Returns*:: Gap object
      def initialize(coord_system, size)
        @coord_system, @size = coord_system, size
      end
      alias length size

      def display_name
        return @coord_system.name + ":gap:" + @size.to_s
      end
    end #Gap

  end #Core
end #Ensembl
