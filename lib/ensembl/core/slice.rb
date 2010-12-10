#
# = ensembl/core/slice.rb - General methods for Ensembl Slice
#
# Copyright::   Copyright (C) 2009 Jan Aerts <http://jandot.myopenid.com>
#               Francesco Strozzi <francesco.strozzi@gmail.com>
#                           
# License::     The Ruby License
#
# @author Jan Aerts
# @author Francesco Strozzi
nil
module Ensembl
  nil
  module Core
        
    # From the perl API tutorial
    # (http://www.ensembl.org/info/software/core/core_tutorial.html): "A
    # Slice object represents a continuous region of a genome. Slices can be
    # used to obtain sequence, features or other information from a
    # particular region of interest."
    #
    # In contrast to almost all other classes of Ensembl::Core,
    # the Slice class is not based on ActiveRecord.
    #
    # @example
    #  chr4 = SeqRegion.find_by_name('4')
    #  my_slice = Slice.new(chr4, 95000, 98000, -1)
    #  puts my_slice.display_name    #--> 'chromosome:4:Btau_3.1:95000:98000:1'
    class Slice
      attr_accessor :seq_region, :start, :stop, :strand, :seq

      #################
      ## CREATE A SLICE
      #################

      # Create a new Slice object from scratch.
      #
      # @example
      #  chr4 = SeqRegion.find_by_name('4')
      #  my_slice = Slice.new(chr4, 95000, 98000, -1)
      # 
      # @param [SeqRegion] seq_region SeqRegion object
      # @param [Integer] start Start position of the slice on the seq_region
      # @param [Integer] stop Stop position of the slice on the seq_region
      # @param [Integer] strand Strand that the slice should be
      # @return [Slice] Slice object
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

      # Create a Slice without first creating the SeqRegion object.
      #
      # @example
      #  my_slice_1 = Slice.fetch_by_region('chromosome','4',95000,98000,1)
      #
      # @param [String] coord_system_name Name of coordinate system
      # @param [String] seq_region_name name of the seq_region
      # @param [Integer] start Start position of the slice on the seq_region
      # @param [Integer] stop Stop position of the slice on the seq_region
      # @param [Integer] strand Strand that the slice should be
      # @param [String] species Name of species in case of multi-species database
      # @param [Integer] version Version number of the coordinate system
      # @return [Slice] Slice object
      def self.fetch_by_region(coord_system_name, seq_region_name, start = nil, stop = nil, strand = 1, species = Ensembl::SESSION.collection_species ,version = nil)
        all_coord_systems = nil
        if Collection.check
          species = species.downcase
          if species.nil?
            raise ArgumentError, "When using multi-species db, you must pass a species name to get the correct Slice"
          else
            species_id = Collection.get_species_id(species)
            raise ArgumentError, "No species found in the database with this name: #{species}" if species_id.nil? 
            all_coord_systems = Ensembl::Core::CoordSystem.find_all_by_name_and_species_id(coord_system_name,species_id)
          end
        else
          all_coord_systems = Ensembl::Core::CoordSystem.find_all_by_name(coord_system_name)
        end
      	coord_system = nil
        if version.nil? # Take the version with the lower rank
          coord_system = all_coord_systems.sort_by{|cs| cs.rank}.shift
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

      # Create a Slice based on a Gene
      #
      # @example
      #  my_slice = Slice.fetch_by_gene_stable_id('ENSG00000184895')
      #
      # @param [String] gene_stable_id Ensembl gene stable ID
      # @param [Integer] flanking_seq_length Length of the flanking sequence
      # @return [Slice] Slice object
      def self.fetch_by_gene_stable_id(gene_stable_id, flanking_seq_length = 0)
        gene_stable_id = Ensembl::Core::GeneStableId.find_by_stable_id(gene_stable_id)
      	gene = gene_stable_id.gene
        seq_region = gene.seq_region

        return Ensembl::Core::Slice.new(seq_region, gene.seq_region_start - flanking_seq_length, gene.seq_region_end + flanking_seq_length, gene.seq_region_strand)
      end

      # Create a Slice based on a Transcript
      #
      # @example
      #  my_slice = Slice.fetch_by_transcript_stable_id('ENST00000383673')
      #
      # @param [String] transcript_stable_id Ensembl transcript stable ID
      # @param [Integer] flanking_seq_length Length of the flanking sequence
      # @return [Slice] Slice object
      def self.fetch_by_transcript_stable_id(transcript_stable_id, flanking_seq_length = 0)
        transcript_stable_id = Ensembl::Core::TranscriptStableId.find_by_stable_id(transcript_stable_id)
      	transcript = transcript_stable_id.transcript
        seq_region = transcript.seq_region

        return Ensembl::Core::Slice.new(seq_region, transcript.seq_region_start - flanking_seq_length, transcript.seq_region_end + flanking_seq_length, transcript.seq_region_strand)
      end

      # Create an array of all Slices for a given coordinate system.
      #
      # @example
      #  slices = Slice.fetch_all('chromosome')
      #
      # @param [String] coord_system_name Name of coordinate system
      # @param [String] species Name of species
      # @param [Integer] version Version of coordinate system
      # @return [Array<Slice>] Array of Slice objects
      def self.fetch_all(coord_system_name = 'chromosome',species = Ensembl::SESSION.collection_species ,version = nil)
        answer = Array.new
        coord_system = nil
      	if Collection.check
      	   species = species.downcase  
      	   species_id = Collection.get_species_id(species)
      	   raise ArgumentError, "No specie found in the database with this name: #{species}" if species_id.nil?
      	   if version.nil?
              coord_system = Ensembl::Core::CoordSystem.find_by_name_and_species_id(coord_system_name,species_id)
           else
              coord_system = Ensembl::Core::CoordSystem.find_by_name_and_species_id_and_version(coord_system_name, species_id, version)
           end  
        else
           if version.nil?
              coord_system = Ensembl::Core::CoordSystem.find_by_name(coord_system_name)
           else
              coord_system = Ensembl::Core::CoordSystem.find_by_name_and_version(coord_system_name, version) 
           end
        end
      	coord_system.seq_regions.each do |seq_region|
      	  answer.push(Ensembl::Core::Slice.new(seq_region))
      	end
        return answer
      end

      ##################
      ## GENERAL METHODS
      ##################

      # Get the length of a slice
      #
      # @example
      #  chr4 = SeqRegion.find_by_name('4')
      #  my_slice = Slice.new(chr4, 95000, 98000, -1)
      #  puts my_slice.length
      # 
      # @return [Integer] Length of the slice
      def length
        return self.stop - self.start + 1
      end

      # The display_name method returns a full name of this slice, containing
      # the name of the coordinate system, the sequence region, start and
      # stop positions on that sequence region and the strand. E.g. for a slice
      # of bovine chromosome 4 from position 95000 to 98000 on the reverse strand,
      # the display_name would look like: chromosome:4:Btau_3.1:95000:98000:-1
      #
      # @example
      #  puts my_slice.display_name
      # 
      # @return [String] Nicely formatted name of the Slice
      def display_name
      	return [self.seq_region.coord_system.name, self.seq_region.coord_system.version, self.seq_region.name, self.start.to_s, self.stop.to_s, self.strand.to_s].join(':')
      end
      alias to_s display_name

      # The Slice#overlaps? method checks if this slice overlaps another one.
      # The other slice has to be on the same coordinate system
      #
      # @example
      #  slice_a = Slice.fetch_by_region('chromosome','X',1,1000)
      #  slice_b = Slice.fetch_by_region('chromosome','X',900,1500)
      #  if slice_a.overlaps?(slice_b)
      #    puts "There slices overlap"
      #  end
      # 
      # @param [Slice] other_slice Another slice
      # @return [Boolean] True if slices overlap, otherwise false
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

      # The Slice#within? method checks if this slice is contained withing another one.
      # The other slice has to be on the same coordinate system
      #
      # @example
      #  slice_a = Slice.fetch_by_region('chromosome','X',1,1000)
      #  slice_b = Slice.fetch_by_region('chromosome','X',900,950)
      #  if slice_b.overlaps?(slice_a)
      #    puts "Slice b is within slice a"
      #  end
      # 
      # @param [Slice] other_slice Another slice
      # @return [Boolean] True if this slice is within other_slice, otherwise false
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

      # The Slice#excise method removes a bit of a slice and returns the 
      # remainder as separate slices.
      #
      # @example
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
      # 
      # @param [Array<Range>] Array of ranges to excise
      # @return [Array<Slice>] Array of slices
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
      # @example
      #  my_slice.seq.seq.to_s
      #
      # @return [Bio::Sequence::NA] Slice sequence as a Bio::Sequence::NA object
      def seq
      	# If we already accessed the sequence, we can just
      	# call the instance variable. Otherwise, we'll have
        # to get the sequence first and create a Bio::Sequence::NA
      	# object.
        if @seq.nil?
          # First check if the slice is on the seqlevel coordinate
      	  # system, otherwise project coordinates.
          if ! Ensembl::SESSION.seqlevel_id.nil? and self.seq_region.coord_system_id == Ensembl::SESSION.seqlevel_id
            @seq = Bio::Sequence::NA.new(self.seq_region.subseq(self.start, self.stop))
          else # we have to project coordinates
            seq_string = String.new
      	    @target_slices = self.project('seqlevel')
            @target_slices.each do |component|
              if component.class == Slice
                seq_string += component.seq # This fetches the seq recursively
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

      # Take a sub_slice from an existing one.
      #
      # @example
      #  my_sub_slice = my_slice.sub_slice(400,500)
      #
      # @param [Integer] start Start of subslice relative to slice
      # @param [Integer] stop Stop of subslice relative to slice
      # @return [Slice] Slice object
      def sub_slice(start = self.start, stop = self.stop)
      	return self.class.new(self.seq_region, start, stop, self.strand)
      end

      # Creates overlapping subslices for a given Slice.
      #
      # @example
      #  my_slice.split(50000, 250).each do |sub_slice|
      #    puts sub_slice.display_name
      #  end
      #
      # @param [Integer] max_size Maximal size of subslices
      # @param [Integer] overlap Overlap in bp between consecutive subslices
      # @return [Array<Slice>] Array of Slice objects
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

        coord_system_ids_with_features = nil
        # Get all the coord_systems with this type of features on them
        if Collection.check
          coord_system_ids_with_features = Collection.find_all_coord_by_table_name(table_name,self.seq_region.coord_system.species_id).collect{|mc| mc.coord_system_id}
        else
          coord_system_ids_with_features = MetaCoord.find_all_by_table_name(table_name).collect{|mc| mc.coord_system_id}
        end  
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


      # Get all MiscFeatures that are located on a Slice for a given MiscSet.
      #
      # Pitfall: just looks at the CoordSystem that the Slice is located on.
      # For example, if a Slice is located on a SeqRegion on the 'chromosome'
      # CoordSystem, but all misc_features are annotated on SeqRegions of
      # the 'scaffold' CoordSystem, this method will return an empty array.
      #
      # @example
      #  my_slice.misc_features('encode').each do |feature|
      #    puts feature.to_yaml
      #  end
      # 
      # @param [String] code Code of MiscSet
      # @return [Array<MiscFeature>] Array of MiscFeature objects
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

      # Get all DnaAlignFeatures that are located on a Slice for a given Analysis.
      #
      # Pitfall: just looks at the CoordSystem that the Slice is located on.
      # For example, if a Slice is located on a SeqRegion on the 'chromosome'
      # CoordSystem, but all dna_align_features are annotated on SeqRegions of
      # the 'scaffold' CoordSystem, this method will return an empty array.
      #
      # @example
      #  my_slice.dna_align_features('Vertrna').each do |feature|
      #    puts feature.to_yaml
      #  end
      # 
      # @param [String] analysis_name Name of analysis
      # @return [Array<DnaAlignFeature>] Array of DnaAlignFeature objects
      def dna_align_features(analysis_name = nil)
      	if analysis_name.nil?
          return DnaAlignFeature.find_by_sql('SELECT * FROM dna_align_feature WHERE seq_region_id = ' + self.seq_region.id.to_s + ' AND seq_region_start >= ' + self.start.to_s + ' AND seq_region_end <= ' + self.stop.to_s)
        else
          analysis = Analysis.find_by_logic_name(analysis_name)
          return DnaAlignFeature.find_by_sql('SELECT * FROM dna_align_feature WHERE seq_region_id = ' + self.seq_region.id.to_s + ' AND seq_region_start >= ' + self.start.to_s + ' AND seq_region_end <= ' + self.stop.to_s + ' AND analysis_id = ' + analysis.id.to_s)
        end
      end

      # Get all ProteinAlignFeatures that are located on a Slice for a given Analysis.
      #
      # Pitfall: just looks at the CoordSystem that the Slice is located on.
      # For example, if a Slice is located on a SeqRegion on the 'chromosome'
      # CoordSystem, but all protein_align_features are annotated on SeqRegions of
      # the 'scaffold' CoordSystem, this method will return an empty array.
      #
      # @example
      #  my_slice.protein_align_features('Uniprot').each do |feature|
      #    puts feature.to_yaml
      #  end
      # 
      # @param [String] analysis_name Name of analysis
      # @return [Array<ProteinAlignFeature>] Array of ProteinAlignFeature objects
      def protein_align_features(analysis_name)
      	if analysis_name.nil?
          return ProteinAlignFeature.find_by_sql('SELECT * FROM protein_align_feature WHERE seq_region_id = ' + self.seq_region.id.to_s + ' AND seq_region_start >= ' + self.start.to_s + ' AND seq_region_end <= ' + self.stop.to_s)
        else
          analysis = Analysis.find_by_logic_name(analysis_name)
          return ProteinAlignFeature.find_by_sql('SELECT * FROM protein_align_feature WHERE seq_region_id = ' + self.seq_region.id.to_s + ' AND seq_region_start >= ' + self.start.to_s + ' AND seq_region_end <= ' + self.stop.to_s + ' AND analysis_id = ' + analysis.id.to_s)
        end
      end
      
      ############################
      ## VARIATION METHODS
      ############################
      
      
      # Method to retrieve Variation features from Ensembl::Core::Slice objects
      # @example
      # slice = Slice.fetch_by_region('chromosome',1,50000,51000)
      # variations = slice.get_variation_features
      # variations.each do |vf|
      #  puts vf.variation_name, vf.allele_string
      #  puts vf.variation.ancestral_allele
      # end
      def get_variation_features
        variation_connection()
        Ensembl::Variation::VariationFeature.find(:all,:conditions => ["seq_region_id = ? AND seq_region_start >= ? AND seq_region_end <= ?",self.seq_region.seq_region_id,self.start,self.stop])
      end
      
      def get_genotyped_variation_features
        variation_connection()
        Ensembl::Variation::VariationFeature.find(:all,:conditions => ["flags = 'genotyped' AND seq_region_id = ? AND seq_region_start >= ? AND seq_region_end <= ?",self.seq_region.seq_region_id,self.start,self.stop])
      end
      
      def get_structural_variations
        variation_connection()
        Ensembl::Variation::StructuralVariation.find(:all,:conditions => ["seq_region_id = ? AND seq_region_start >= ? AND seq_region_end <= ?",self.seq_region.seq_region_id,self.start,self.stop])
      end
      
      private 
      
      def variation_connection()
        if !Ensembl::Variation::DBConnection.connected?  
          host,user,password,db_name,port,species,release = Ensembl::Core::DBConnection.get_info
          Ensembl::Variation::DBConnection.connect(species,release.to_i,:username => user, :password => password,:host => host, :port => port)
        end
        
      end  
      
      
    end #Slice

    # The Gap class is similar to the Slice object, but describes a gap and
    # therefore can easily be described by coordinate system and size.
    #
    class Gap
      attr_accessor :coord_system, :size

      # Create a new Gap object from scratch.
      #
      # @example
      #  my_coord_system = CoordSystem.find_by_name('chromosome')
      #  # Create a gap of 10kb.
      #  gap = Gap.new(my_coord_system, 10000)
      # 
      # @param [CoordSystem] coord_system Coordinate system object
      # @param [Integer] size Length of the gap
      # @return [Gap] Gap object
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
