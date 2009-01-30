#
# = ensembl/core/activerecord.rb - ActiveRecord mappings to Ensembl core
#
# Copyright::   Copyright (C) 2007 Jan Aerts <http://jandot.myopenid.com>
# License::     The Ruby License
#

# = DESCRIPTION
# == What is it?
# The Ensembl module provides an API to the Ensembl databases
# stored at ensembldb.ensembl.org. This is the same information that is
# available from http://www.ensembl.org.
#
# The Ensembl::Core module mainly covers sequences and
# annotations.
# The Ensembl::Variation module covers variations (e.g. SNPs).
# The Ensembl::Compara module covers comparative mappings
# between species.
#
# == ActiveRecord
# The Ensembl API provides a ruby interface to the Ensembl mysql databases
# at ensembldb.ensembl.org. Most of the API is based on ActiveRecord to
# get data from that database. In general, each table is described by a
# class with the same name: the coord_system table is covered by the
# CoordSystem class, the seq_region table is covered by the SeqRegion class,
# etc. As a result, accessors are available for all columns in each table.
# For example, the seq_region table has the following columns: seq_region_id,
# name, coord_system_id and length. Through ActiveRecord, these column names
# become available as attributes of SeqRegion objects:
#   puts my_seq_region.seq_region_id
#   puts my_seq_region.name
#   puts my_seq_region.coord_system_id
#   puts my_seq_region.length.to_s
#
# ActiveRecord makes it easy to extract data from those tables using the
# collection of #find methods. There are three types of #find methods (e.g.
# for the CoordSystem class):
# a. find based on primary key in table:
#  my_coord_system = CoordSystem.find(5)
# b. find_by_sql:
#  my_coord_system = CoordSystem.find_by_sql('SELECT * FROM coord_system WHERE name = 'chromosome'")
# c. find_by_<insert_your_column_name_here>
#  my_coord_system1 = CoordSystem.find_by_name('chromosome')
#  my_coord_system2 = CoordSystem.find_by_rank(3)
# To find out which find_by_<column> methods are available, you can list the
# column names using the column_names class methods:
#
#  puts Ensembl::Core::CoordSystem.column_names.join("\t")
#
# For more information on the find methods, see
# http://ar.rubyonrails.org/classes/ActiveRecord/Base.html#M000344
#
# The relationships between different tables are accessible through the
# classes as well. For example, to loop over all seq_regions belonging to
# a coord_system (a coord_system "has many" seq_regions):
#   chr_coord_system = CoordSystem.find_by_name('chromosome')
#   chr_coord_system.seq_regions.each do |seq_region|
#     puts seq_region.name
#   end
# Of course, you can go the other way as well (a seq_region "belongs to"
# a coord_system):
#   chr4 = SeqRegion.find_by_name('4')
#   puts chr4.coord_system.name  #--> 'chromosome'
#
# To find out what relationships exist for a given class, you can use the
# #reflect_on_all_associations class methods:
#  puts SeqRegion.reflect_on_all_associations(:has_many).collect{|a| a.name.to_s}.join("\n")
#  puts SeqRegion.reflect_on_all_associations(:has_one).collect{|a| a.name.to_s}.join("\n")
#  puts SeqRegion.reflect_on_all_associations(:belongs_to).collect{|a| a.name.to_s}.join("\n")
module Ensembl
  # = DESCRIPTION
  # The Ensembl::Core module covers the core databases from
  # ensembldb.ensembl.org and covers mainly sequences and their annotations.
  # For a full description of the database (and therefore the classes that
  # are available), see http://www.ensembl.org/info/software/core/schema/index.html
  # and http://www.ensembl.org/info/software/core/schema/schema_description.html
  module Core
    # = DESCRIPTION
    # The Sliceable mixin holds the get_slice method and can be included
    # in any class that lends itself to having a position on a SeqRegion.
    module Sliceable
      # = DESCRIPTION
      # The Sliceable#slice method takes the coordinates on a reference
      # and creates a Ensembl::Core::Slice object.
      # ---
      # *Arguments*:: none
      # *Returns*:: Ensembl::Core::Slice object
      def slice
        start, stop, strand = nil, nil, nil
        
      	if self.class == Ensembl::Core::Intron or self.class.column_names.include?('seq_region_start')
          start = self.seq_region_start
        end
      	if self.class == Ensembl::Core::Intron or self.class.column_names.include?('seq_region_end')
          stop = self.seq_region_end
        end
      	if self.class == Ensembl::Core::Intron or self.class.column_names.include?('seq_region_strand')
          strand = self.seq_region_strand
      	else #FIXME: we shouldn't do this, but can't #project if no strand given
          strand = 1
        end
      
        return Ensembl::Core::Slice.new(self.seq_region, start, stop, strand)
      end
      
      # = DESCRIPTION
      # The Sliceable#seq method takes the coordinates on a reference, transforms
      # onto the seqlevel coordinate system if necessary, and retrieves the
      # sequence.
      # ---
      # *Arguments*:: none
      # *Returns*:: sequence
      def seq
        return self.slice.seq
      end
      
      # = DESCRIPTION
      # The Sliceable#start method is a convenience method and returns
      # self.seq_region_start.
      # ---
      # *Arguments*:: none
      # *Returns*:: sequence
      def start
        return self.seq_region_start
      end
      
      # = DESCRIPTION
      # The Sliceable#stop method is a convenience method and returns
      # self.seq_region_end.
      # ---
      # *Arguments*:: none
      # *Returns*:: sequence
      def stop
        return self.seq_region_end
      end
      
      # = DESCRIPTION
      # The Sliceable#strand method is a convenience method and returns
      # self.seq_region_strand.
      # ---
      # *Arguments*:: none
      # *Returns*:: sequence
      def strand
        return self.seq_region_strand
      end
      
      # = DESCRIPTION
      # The Sliceable#length method returns the length of the feature (based on
      # seq_region_start and seq_region_end.
      # ---
      # *Arguments*:: none
      # *Returns*:: sequence
      def length
        return self.stop - self.start + 1
      end
      
      # = DESCRIPTION
      # The Sliceable#project method is used to transfer coordinates from one
      # coordinate system to another. Suppose you have a feature on a
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
      #  original_feature = Gene.find(85743)
      #  target_slices = original_feature.project('scaffold')
      #
      # ---
      # *Arguments*:
      # * coord_system_name:: name of coordinate system to project
      #   coordinates to
      # *Returns*:: an array consisting of Slices and, if necessary, Gaps
      def project(coord_system_name)
        return self.slice.project(coord_system_name)
      end

    end


    # = DESCRIPTION
    # The CoordSystem class describes the coordinate system to which
    # a given SeqRegion belongs. It is an interface to the coord_system
    # table of the Ensembl mysql database.
    #
    # Two virtual coordinate systems exist for
    # every species:
    # * toplevel: the coordinate system with rank 1
    # * seqlevel: the coordinate system that contains the seq_regions
    #	with the sequence
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  coord_system = Ensembl::Core::CoordSystem.find_by_name('chromosome')
    #  if coord_system == CoordSystem.toplevel
    #	 puts coord_system.name + " is the toplevel coordinate system."
    #  end
    class CoordSystem < DBConnection
      set_primary_key 'coord_system_id'

      has_many :seq_regions

      # = DESCRIPTION
      # The CoordSystem#toplevel? method checks if this coordinate system is the
      # toplevel coordinate system or not.
      # ---
      # *Arguments*:: none
      # *Returns*:: TRUE or FALSE
      def toplevel?
        if self == CoordSystem.find_by_rank(1)
          return true
        else
          return false
        end
      end

      # = DESCRIPTION
      # The CoordSystem#seqlevel? method checks if this coordinate system is the
      # seqlevel coordinate system or not.
      # ---
      # *Arguments*:: none
      # *Returns*:: TRUE or FALSE
      def seqlevel?
        if self == CoordSystem.find_by_sql("SELECT * FROM coord_system WHERE attrib LIKE '%sequence_level%'")[0]
          return true
        else
          return false
        end
      end
      
      # = DESCRIPTION
      # The CoordSystem#find_toplevel class method returns the toplevel coordinate
      # system.
      # ---
      # *Arguments*:: none
      # *Returns*:: CoordSystem object
      def self.find_toplevel
        return CoordSystem.find_by_rank(1)
      end
      
      # = DESCRIPTION
      # The CoordSystem#find_seqlevel class method returns the seqlevel coordinate
      # system.
      # ---
      # *Arguments*:: none
      # *Returns*:: CoordSystem object
      def self.find_seqlevel
        return CoordSystem.find_by_sql("SELECT * FROM coord_system WHERE attrib LIKE '%sequence_level%'")[0]
      end
      
      # = DESCRIPTION
      # The CoordSystem#find_default_by_name class method returns the
      # coordinate system by that name with the lowest rank. Normally, a lower
      # rank means a 'bigger' coordinate system. The 'chromosome' typically has
      # rank 1. However, there might be more than one coordinate system with the
      # name chromosome but with different version (e.g. in human, there is one
      # for the NCBI36 and one for the NCBI35 version). The older version of these
      # is typically given a high number and the one with the new version is the
      # 'default' system.
      # ---
      # *Arguments*:: none
      # *Returns*:: CoordSystem object
      def self.find_default_by_name(name)
        all_coord_systems_with_name = Ensembl::Core::CoordSystem.find_all_by_name(name)
        if all_coord_systems_with_name.length == 1
          return all_coord_systems_with_name[0]
        else
          return all_coord_systems_with_name.select{|cs| cs.attrib =~ /default_version/}[0]
        end
      end
      
      # = DESCRIPTION
      # The CoordSystem#name_with_version returns a string containing the name
      # and version of the coordinate system. If no version is available, then
      # just the name is returned
      # ---
      # *Arguments*:: none
      # *Returns*:: String object
      def name_with_version
        if self.version.nil?
          return name
        else
          return [name, version].join(':')
        end
      end
      
      ## Calculate the shortest path between a source coordinate system and a
      ## target coordinate system. This can be done by looking for the
      ## 'assembly.mapping' records in the meta_coord table.
      ## At the moment, only direct mappings are possible. Later on, this method
      ## should be changed to make longer paths possible.
      ## Is used to get features for a slice object.
      #def calculate_path(target_coord_system)
      #  MetaCoord.find_all_by_meta_key('assembly.mapping').each do |mapping|
      #    coord_system_names = mapping.meta_value.split(/[#|\|]/)
      #    if coord_system_names.sort.join(';') == [self.name_with_version, target_coord_system.name_with_version].sort.join(';')
      #      answer = Array.new
      #      answer.push(CoordSystem.find_by_name(coord_system_names[0]))
      #      answer.push(CoordSystem.find_by_name(coord_system_names[1]))
      #      return answer
      #    end
      #  end
      #  return nil
      #  
      #end
    end

    # = DESCRIPTION
    # The SeqRegion class describes a part of a coordinate systems. It is an
    # interface to the seq_region table of the Ensembl mysql database.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  chr4 = SeqRegion.find_by_name('4')
    #  puts chr4.coord_system.name     #--> 'chromosome'
    #  chr4.genes.each do |gene|
    #	 puts gene.biotype
    #  end
    class SeqRegion < DBConnection
      set_primary_key 'seq_region_id'

      belongs_to :coord_system
      has_many :simple_features
      has_many :marker_features
      has_many :genes
      has_many :exons
      has_many :repeat_features
      has_many :seq_region_attribs
      has_many :attrib_types, :through => :seq_region_attrib
      has_many :transcripts
      has_one :dna
      has_many :dna_align_features
      has_many :misc_features
      has_many :density_features
      has_many :karyotypes
      has_many :oligo_features
      has_many :prediction_exons
      has_many :prediction_transcripts
      has_many :protein_align_features
      has_many :regulatory_features
      has_many :assembly_exceptions

      # See http://blog.hasmanythrough.com/2006/4/21/self-referential-through
      has_many :asm_links_as_asm, :foreign_key => 'asm_seq_region_id', :class_name => 'AssemblyLink'
      has_many :asm_links_as_cmp, :foreign_key => 'cmp_seq_region_id', :class_name => 'AssemblyLink'
      has_many :asm_seq_regions, :through => :asm_links_as_cmp
      has_many :cmp_seq_regions, :through => :asm_links_as_asm

      alias attribs seq_region_attribs
      
      # = DESCRIPTION
      # The SeqRegion#slice method returns a slice object that covers the whole
      # of the seq_region.
      # ---
      # *Arguments*:: none
      # *Returns*:: Ensembl::Core::Slice object
      def slice
        return Ensembl::Core::Slice.new(self)
      end
      
      # = DESCRIPTION
      # The SeqRegion#assembled_seq_regions returns the sequence regions on which
      # the current region is assembled. For example, calling this method on a
      # contig sequence region, it might return the chromosome that that contig
      # is part of. Optionally, this method takes a coordinate system name so
      # that only regions of that coordinate system are returned.
      # ---
      # *Arguments*:: coord_system_name (optional)
      # *Returns*:: array of SeqRegion objects
      def assembled_seq_regions(coord_system_name = nil)
        if coord_system_name.nil?
          return self.asm_seq_regions
        else
          answer = Array.new
      	  coord_system = CoordSystem.find_by_name(coord_system_name)
          self.asm_seq_regions.each do |asr|
            if asr.coord_system_id == coord_system.id
              answer.push(asr)
            end
          end
      	  return answer
        end
      end

      # = DESCRIPTION
      # The SeqRegion#component_seq_regions returns the sequence regions
      # contained within the current region (in other words: the bits used to
      # assemble the current region). For example, calling this method on a
      # chromosome sequence region, it might return the contigs that were assembled
      # into this chromosome. Optionally, this method takes a coordinate system
      # name so that only regions of that coordinate system are returned.
      # ---
      # *Arguments*:: coord_system_name (optional)
      # *Returns*:: array of SeqRegion objects
      def component_seq_regions(coord_system_name = nil)
      	if coord_system_name.nil?
          return self.cmp_seq_regions
        else
          answer = Array.new
      	  coord_system = CoordSystem.find_by_name(coord_system_name)
          self.cmp_seq_regions.each do |csr|
            if csr.coord_system_id == coord_system.id
              answer.push(csr)
            end
          end
      	  return answer
        end
      end

      # = DESCRIPTION
      # This method queries the assembly table to find those rows (i.e.
      # AssemblyLink objects) for which this seq_region is the assembly.
      #
      # = USAGE
      #
      #  my_seq_region = SeqRegion.find('4')
      #  first_link = my_seq_region.assembly_links_as_assembly[0]
      #  puts first_link.asm_start.to_s + "\t" + first_link.asm_end.to_s
      #
      # ---
      # *Arguments*:
      # * coord_system_name: name of coordinate system that the components
      #   should belong to (default = nil)
      # *Returns*:: array of AssemblyLink objects
      def assembly_links_as_assembly(coord_system_name = nil)
      	if coord_system_name.nil?
          return self.asm_links_as_asm
        else
          coord_system = CoordSystem.find_by_name(coord_system_name)
#      	  return self.asm_links_as_asm.select{|alaa| alaa.cmp_seq_region.coord_system_id == coord_system.id}
          return AssemblyLink.find_by_sql("SELECT * FROM assembly a WHERE a.asm_seq_region_id = " + self.id.to_s + " AND a.cmp_seq_region_id IN (SELECT sr.seq_region_id FROM seq_region sr WHERE coord_system_id = " + coord_system.id.to_s + ")")
        end
      end

      # = DESCRIPTION
      # This method queries the assembly table to find those rows (i.e.
      # AssemblyLink objects) for which this seq_region is the component.
      #
      # = USAGE
      #
      #  my_seq_region = SeqRegion.find('Chr4.003.1')
      #  first_link = my_seq_region.assembly_links_as_component[0]
      #  puts first_link.asm_start.to_s + "\t" + first_link.asm_end.to_s
      #
      # ---
      # *Arguments*:
      # * coord_system_name: name of coordinate system that the assembly
      #   should belong to (default = nil)
      # *Returns*:: array of AssemblyLink objects
      def assembly_links_as_component(coord_system_name = nil)
        if coord_system_name.nil?
          return self.asm_links_as_cmp
        else
          coord_system = CoordSystem.find_by_name(coord_system_name)
      	  return self.asm_links_as_cmp.select{|alac| alac.asm_seq_region.coord_system_id == coord_system.id}
        end
      end

      # = DESCRIPTION
      # The SeqRegion#sequence method returns the sequence of this seq_region. At
      # the moment, it will only return the sequence if the region belongs to the
      # seqlevel coordinate system.
      # ---
      # *Arguments*:: none
      # *Returns*:: DNA sequence as String
      def sequence
        return self.dna.sequence
      end
      alias seq sequence

      # = DESCRIPTION
      # The SeqRegion#subsequence method returns a subsequence of this seq_region. At
      # the moment, it will only return the sequence if the region belongs to the
      # seqlevel coordinate system.
      # ---
      # *Arguments*:: start and stop position
      # *Returns*:: DNA sequence as String
      def subsequence(start, stop)
      	return self.seq.slice(start - 1, (stop - start) + 1)
      end
      alias subseq subsequence

    end

    # = DESCRIPTION
    # The AssemblyLink class describes the relationships between different
    # seq_regions. For example, a chromosome might consist of a number of
    # scaffolds, each of which in turn consists of a number of contigs. The
    # AssemblyLink class
    # This class is an interface to the assembly table of the Ensembl mysql
    # database.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  chr4 = SeqRegion.find_by_name('4')
    #  puts chr4.coord_system.name     #--> 'chromosome'
    #  chr4.genes.each do |gene|
    #	 puts gene.biotype
    #  end
    class AssemblyLink < DBConnection
      set_table_name 'assembly'
      set_primary_key nil

      # See http://blog.hasmanythrough.com/2006/4/21/self-referential-through
      belongs_to :asm_seq_region, :foreign_key => 'asm_seq_region_id', :class_name => 'SeqRegion'
      belongs_to :cmp_seq_region, :foreign_key => 'cmp_seq_region_id', :class_name => 'SeqRegion'
    end

    # = DESCRIPTION
    # The AssemblyException class describes the exceptions in to AssemblyLink. Most
    # notably, this concerns the allosomes. In human, for example, only the
    # part of the Y chromosome that is different from X is covered in the
    # assembly table. Therefore, the sequence of the tip and end of the Y
    # chromosome are not stored in the database, but fetched from the X
    # chromosome. The assembly_exception table contain the information on
    # which bits are the same.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class should normally not be used directly by the user.   
    class AssemblyException < DBConnection
      include Sliceable
      
      set_primary_key 'assembly_exception_id'
      
      belongs_to :seq_region
    end

    # = DESCRIPTION
    # The MetaCoord class describes what coordinate systems are used to annotate
    # features. It will for example tell you that marker_features are annotated
    # either on the chromosome, supercontig and clone level.
    #
    # This class should normally not be used by the end user, but is used internally.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class MetaCoord < DBConnection
      set_primary_key nil
    end

    # = DESCRIPTION
    # The Meta class describes meta data of the database. These include information
    # on what coordinate system is mapping on another one and which patches
    # are applied.
    #
    # This class should normally not be used by the end user, but is used internally.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class Meta < DBConnection
      set_primary_key nil
    end

    # = DESCRIPTION
    # The Analysis class describes an analysis.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  repeat_masker_analysis = Analysis.find_by_logic_name('RepeatMask')
    #  puts repeat_masker_analysis.to_yaml
    class Analysis < DBConnection
      set_primary_key 'analysis_id'

      has_many :dna_align_features
      has_many :protein_align_features
      has_one :analysis_description
      has_many :density_types
      has_many :oligo_features
      has_many :protein_features
      has_many :regulatory_features
      has_many :simple_features
      has_many :prediction_transcripts
    end

    # = DESCRIPTION
    # The AnalysisDescription class belongs to an analysis.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  descr = AnalysisDescription.find(3)
    #  puts descr.to_yaml
    class AnalysisDescription < DBConnection
      set_primary_key nil

      belongs_to :analysis
    end

    # = DESCRIPTION
    # The Dna class contains the actual DNA sequence for the sequence regions
    # that belong to the seq_level coordinate system.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  seq_region = SeqRegion.find(1)
    #  puts seq_region.dna.sequence
    class Dna < DBConnection
      set_primary_key nil

      belongs_to :seq_region
    end

    # = DESCRIPTION
    # The Exon class describes an exon.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  seq_region = SeqRegion.find(1)
    #  puts seq_region.exons.length
    class Exon < DBConnection
      include Sliceable

      set_primary_key 'exon_id'

      belongs_to :seq_region
      has_many :exon_transcripts
      has_many :transcripts, :through => :exon_transcripts

      has_many :translations, :foreign_key => 'start_exon_id'
      has_many :translations, :foreign_key => 'end_exon_id'

      has_one :exon_stable_id

      has_many :exon_supporting_features
      has_many :dna_align_features, :through => :exon_supporting_features, :conditions => ["feature_type = 'dna_align_feature'"]
      has_many :protein_align_features, :through => :exon_supporting_features, :conditions => ["feature_type = 'protein_align_feature'"]

      def stable_id
        return self.exon_stable_id.stable_id
      end

      # = DESCRIPTION
      # The Exon#seq method returns the sequence of the exon.
      def seq
      	slice = Ensembl::Core::Slice.new(self.seq_region, seq_region_start, seq_region_end, seq_region_strand)
        return slice.seq
      end
    end

    # = DESCRIPTION
    # The ExonStableId class provides an interface to the exon_stable_id
    # table. This table contains Ensembl stable IDs for exons.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  my_exon = ExonStableId.find_by_stable_id('ENSE00001494622').exon
    class ExonStableId < DBConnection
      set_primary_key 'stable_id'
      
      belongs_to :exon
    end

    # = DESCRIPTION
    # The ExonTranscript class provides the link between exons and transcripts.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  link = ExonTranscript.find(1)
    #  puts link.exon.to_yaml
    #  puts link.transcript.to_yaml
    class ExonTranscript < DBConnection
      set_primary_key nil

      belongs_to :exon
      belongs_to :transcript
    end

    class ExonSupportingFeature < DBConnection
      set_table_name 'supporting_feature'
      set_primary_key nil
      
      belongs_to :exon
      belongs_to :dna_align_feature, :class_name => "DnaAlignFeature", :foreign_key => 'feature_id'
      belongs_to :protein_align_feature, :class_name => "ProteinAlignFeature", :foreign_key => 'feature_id'
    end
    
    class TranscriptSupportingFeature < DBConnection
      set_primary_key nil
      
      belongs_to :transcript
      belongs_to :dna_align_feature, :class_name => "DnaAlignFeature", :foreign_key => 'feature_id'
      belongs_to :protein_align_feature, :class_name => "ProteinAlignFeature", :foreign_key => 'feature_id'
    end

    # = DESCRIPTION
    # The SimpleFeature class describes simple features that have positions
    # on a SeqRegion.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  simple_feature = SimpleFeature.find(123)
    #  puts simple_feature.analysis.logic_name
    class SimpleFeature < DBConnection
      include Sliceable

      set_primary_key 'simple_feature_id'

      belongs_to :seq_region
      belongs_to :analysis
    end

    # = DESCRIPTION
    # The DensityFeature class provides an interface to the density_feature
    # table.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  density_feature = DensityFeature.find(2716384)
    #  puts density_feature.to_yaml
    class DensityFeature < DBConnection
      set_primary_key 'density_feature_id'

      belongs_to :density_type
      belongs_to :seq_region
    end

    # = DESCRIPTION
    # The DensityType class provides an interface to the density_type
    # table.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    class DensityType < DBConnection
      set_primary_key 'density_type_id'

      has_many :density_features
      belongs_to :analysis
    end

    # = DESCRIPTION
    # The Marker class provides an interface to the marker
    # table. This table contains primer sequences and PCR product lengths.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  marker = Marker.find(52194)
    #  puts marker.left_primer
    #  puts marker.right_primer
    #  puts marker.min_primer_dist.to_s
    class Marker < DBConnection
      set_primary_key 'marker_id'

      has_many :marker_features
      has_many :marker_synonyms
      has_many :marker_map_locations

      def self.inheritance_column
        nil
      end

      # = DESCRIPTION
      # The Marker#name method returns a comma-separated list of synonyms of
      # this marker
      #
      # = USAGE
      #  marker = Marker.find(1)
      #  puts marker.name    --> 58017,D29149
      def name
      	self.marker_synonyms.collect{|ms| ms.name}.join(',')
      end

      # = DESCRIPTION
      # The Marker#find_by_name class method returns one marker with this name.
      #
      # ---
      # *Arguments*:: name
      # *Returns*:: Marker object or nil
      def self.find_by_name(name)
        all_names = self.find_all_by_name(name)
        if all_names.length == 0
          return nil
        else
          return all_names[0]
        end
      end

      # = DESCRIPTION
      # The Marker#find_all_by_name class method returns all markers with this
      # name. If no marker is found, it returns an empty array.
      # ---
      # *Arguments*:: name
      # *Returns*:: empty array or array of Marker objects
      def self.find_all_by_name(name)
      	marker_synonyms = Ensembl::Core::MarkerSynonym.find_all_by_name(name)
        answers = Array.new
      	marker_synonyms.each do |ms|
          answers.push(Ensembl::Core::Marker.find_all_by_marker_id(ms.marker_id))
        end
      	answers.flatten!
        return answers
      end

      #def to_mappings
      #	output = Array.new
      #  self.marker_features.each do |mf|
      #    output.push(mf.slice.display_name)
      #  end
      #	return output.join("\n")
      #
      #end
      
    end

    # = DESCRIPTION
    # The MarkerSynonym class provides an interface to the marker_synonym
    # table. This table contains names for markers (that are themselves
    # stored in the marker table (so Marker class)).
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  marker = Marker.find(52194)
    #  puts marker.marker_synonym.source
    #  puts marker.marker_synonym.name
    class MarkerSynonym < DBConnection
      set_primary_key 'marker_synonym_id'

      belongs_to :marker
    end

    # = DESCRIPTION
    # The MarkerFeature class provides an interface to the marker_feature
    # table. This table contains mappings of markers to a SeqRegion.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  marker = Marker.find(52194)
    #  puts marker.marker_feature.seq_region_start.to_s
    #  puts marker.marker_feature.seq_region_end.to_s
    class MarkerFeature < DBConnection
      include Sliceable

      set_primary_key 'marker_feature_id'

      belongs_to :marker
      belongs_to :seq_region
    end

    # = DESCRIPTION
    # The MiscFeature class provides an interface to the misc_feature
    # table. The actual type of feature is stored in the MiscSet class.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  #TODO
    class MiscFeature < DBConnection
      include Sliceable

      set_primary_key 'misc_feature_id'

      belongs_to :seq_region
      has_one :misc_feature_misc_set
      has_many :misc_sets, :through => :misc_feature_misc_set

      has_many :misc_attribs

      alias attribs misc_attribs
      
      def self.find_by_attrib_type_value(code, value)
        return self.find_all_by_attrib_type_value(code, value)[0]
      end
      
      def self.find_all_by_attrib_type_value(code, value)
        code_id = AttribType.find_by_code(code)
      	misc_attribs = MiscAttrib.find_all_by_attrib_type_id_and_value(code_id, value)
        answers = Array.new
      	misc_attribs.each do |ma|
          answers.push(MiscFeature.find_all_by_misc_feature_id(ma.misc_feature_id))
        end
      	answers.flatten!
        return answers
      end
    end


    # = DESCRIPTION
    # The MiscAttrib class provides an interface to the misc_attrib
    # table. It is the link between MiscFeature and AttribType.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  marker = Marker.find(52194)
    #  puts marker.marker_feature.seq_region_start.to_s
    #  puts marker.marker_feature.seq_region_end.to_s
    class MiscAttrib < DBConnection
      set_primary_key nil

      belongs_to :misc_feature
      belongs_to :attrib_type
      
      def to_s
        return self.attrib_type.code + ":" + self.value.to_s
      end
    end

    # = DESCRIPTION
    # The MiscSet class provides an interface to the misc_set
    # table. This table contains the sets to which MiscFeature objects
    # belong.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  feature_set = MiscFeature.find(1)
    #  puts feature_set.features.length.to_s
    class MiscSet < DBConnection
      set_primary_key 'misc_set_id'

      has_many :misc_feature_misc_sets
      has_many :misc_features, :through => :misc_feature_misc_set
    end

    # = DESCRIPTION
    # The MiscFeatureMiscSet class provides an interface to the
    # misc_feature_misc_set table. This table links MiscFeature objects to
    # their MiscSet.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  # TODO
    class MiscFeatureMiscSet < DBConnection
      set_primary_key nil

      belongs_to :misc_feature
      belongs_to :misc_set
    end

    # = DESCRIPTION
    # The Gene class provides an interface to the gene
    # table. This table contains mappings of genes to a SeqRegion.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  puts Gene.find_by_biotype('protein_coding').length
    class Gene < DBConnection
      include Sliceable

      set_primary_key 'gene_id'

      belongs_to :seq_region
      has_one :gene_stable_id

      has_many :gene_attribs
      has_many :attrib_types, :through => :gene_attrib

      has_many :transcripts

      has_many :object_xrefs, :foreign_key => 'ensembl_id', :conditions => "ensembl_object_type = 'Gene'"
      has_many :xrefs, :through => :object_xrefs

      alias attribs gene_attribs

      # = DESCRIPTION
      # The Gene#stable_id method returns the stable_id of the gene (i.e. the
      # ENSG id).
      def stable_id
        return self.gene_stable_id.stable_id
      	
      end

      # = DESCRIPTION
      # The Gene#display_label method returns the default name of the gene.
      def display_label
        return Xref.find(self.display_xref_id).display_label
      end
      alias :display_name :display_label
      alias :label :display_label
      alias :name :display_label

      # = DESCRIPTION
      # The Gene#find_all_by_name class method searches the Xrefs for that name
      # and returns an array of the corresponding Gene objects. If the name is
      # not found, it returns an empty array.
      def self.find_all_by_name(name)
      	answer = Array.new
        xrefs = Ensembl::Core::Xref.find_all_by_display_label(name)
        xrefs.each do |xref|
          answer.push(Ensembl::Core::Gene.find_by_display_xref_id(xref.xref_id))
        end
      
      	return answer
      end
      
      # = DESCRIPTION
      # The Gene#find_by_name class method searches the Xrefs for that name
      # and returns one Gene objects (even if there should be more). If the name is
      # not found, it returns nil.
      def self.find_by_name(name)
        all_names = self.find_all_by_name(name)
        if all_names.length == 0
          return nil
        else
          return all_names[0]
        end
      end
      
      # = DESCRIPTION
      # The Gene#find_by_stable_id class method fetches a Gene object based on
      # its stable ID (i.e. the "ENSG" accession number). If the name is
      # not found, it returns nil.
      def self.find_by_stable_id(stable_id)
        gene_stable_id = GeneStableId.find_by_stable_id(stable_id)
        if gene_stable_id.nil?
          return nil
        else
          return gene_stable_id.gene
        end
      end
      
      # = DESCRIPTION
      # The Gene#all_xrefs method is a convenience method in that it combines
      # three methods into one. It collects all xrefs for the gene itself, plus
      # all xrefs for all transcripts for the gene, and all xrefs for all
      # translations for those transcripts.
      def all_xrefs
        answer = Array.new
        answer.push(self.xrefs)
        self.transcripts.each do |transcript|
          answer.push(transcript.xrefs)
          if ! transcript.translation.nil?
            answer.push(transcript.translation.xrefs)
          end
        end
        answer.flatten!
        return answer
      end
      
      # = DESCRIPTION
      # The Gene#go_terms method returns all GO terms associated with a gene.
      def go_terms
        go_db_id = ExternalDb.find_by_db_name('GO').id
        return self.all_xrefs.select{|x| x.external_db_id == go_db_id}.collect{|x| x.dbprimary_acc}.uniq
      end
      
      # = DESCRIPTION
      # The Gene#hgnc returns the HGNC symbol for the gene.
      def hgnc
        hgnc_db_id = ExternalDb.find_by_db_name('HGNC_curated_gene').id
        xref = self.all_xrefs.select{|x| x.external_db_id == hgnc_db_id}[0]
        return nil if xref.nil?
        return xref.display_label
      end

    end

    # = DESCRIPTION
    # The GeneStableId class provides an interface to the gene_stable_id
    # table. This table contains Ensembl stable IDs for genes.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  my_gene = GeneStableId.find_by_stable_id('ENSBTAG00000011670').gene
    class GeneStableId < DBConnection
      set_primary_key 'stable_id'

      belongs_to :gene
    end

    # = DESCRIPTION
    # The MarkerMapLocation class provides an interface to the
    # marker_map_location table. This table contains mappings of
    # MarkerSynonym objects to a chromosome, and basically just stores
    # the genetic maps.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  marker_synonym = MarkerSynonym.find_by_name('CYP19A1_(5)')
    #  marker_synonym.marker_map_locations.each do |mapping|
    #	 puts mapping.chromosome_name + "\t" + mapping.position.to_s
    #  end
    class MarkerMapLocation < DBConnection
      set_primary_key nil

      belongs_to :map
      belongs_to :marker
      
    end

    # = DESCRIPTION
    # The Map class provides an interface to the map
    # table. This table contains genetic maps.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  map = Map.find_by_name('MARC')
    #  puts map.markers.length.to_s
    class Map < DBConnection
      set_primary_key 'map_id'

      has_many :marker_map_locations
      has_many :markers, :through => :marker_map_locations

      def name
      	return self.map_name
      end
    end

    # = DESCRIPTION
    # The RepeatConsensus class provides an interface to the repeat_consensus
    # table. This table contains consensus sequences for repeats.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  repeat = RepeatFeature.find(29)
    #  puts repeat.repeat_consensus.repeat_name + "\t" + repeat.repeat_consensus.repeat_consensus
    class RepeatConsensus < DBConnection
      set_primary_key 'repeat_consensus_id'

      has_many :repeat_features
    end

    # = DESCRIPTION
    # The RepeatFeature class provides an interface to the repeat_feature
    # table. This table contains mappings of repeats to a SeqRegion.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  repeat_feature = RepeatFeature.find(29)
    #  puts repeat_feature.seq_region_start.to_s
    class RepeatFeature < DBConnection
      include Sliceable

      set_primary_key 'repeat_feature_id'

      belongs_to :repeat_consensus
      belongs_to :seq_region
    end

    # = DESCRIPTION
    # The SeqRegionAttrib class provides an interface to the seq_region_attrib
    # table. This table contains attribute values for SeqRegion objects
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  chr4 = SeqRegion.find_by_name('4')
    #  chr4.seq_region_attribs.each do |attrib|
    #	 puts attrib.attrib_type.name + "\t" + attrib.value.to_s
    #  end
    class SeqRegionAttrib < DBConnection
      set_primary_key nil

      belongs_to :seq_region
      belongs_to :attrib_type
    end

    # = DESCRIPTION
    # The GeneAttrib class provides an interface to the gene_attrib
    # table. This table contains attribute values for Gene objects
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  #TODO
    class GeneAttrib < DBConnection
      set_primary_key nil

      belongs_to :gene
      belongs_to :attrib_type
    end

    # = DESCRIPTION
    # The AttribType class provides an interface to the attrib_type
    # table. This table contains the types that attributes can belong to for
    # SeqRegion, Gene and Transcript.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  #TODO
    class AttribType < DBConnection
      set_primary_key 'attrib_type_id'

      has_many :seq_region_attribs
      has_many :seq_regions, :through => :seq_region_attrib

      has_many :gene_attribs
      has_many :genes, :through => :gene_attrib

      has_many :transcript_attribs
      has_many :transcripts, :through => :transcript_attrib
    end

    # = DESCRIPTION
    # The Transcript class provides an interface to the transcript_stable_id
    # table. This table contains the Ensembl stable IDs for Transcript
    # objects.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  transcript_stable_id = TranscriptStableId.find_by_stable_id('ENSBTAT00000015494')
    #  puts transcript_stable_id.transcript.to_yaml
    class TranscriptStableId < DBConnection
      set_primary_key 'stable_id'

      belongs_to :transcript
    end

    # = DESCRIPTION
    # The TranscriptAttrib class provides an interface to the transcript_attrib
    # table. This table contains the attributes for Transcript objects.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  transcript = Transcript.find(32495)
    #  transcript.transcript_attribs.each do |attr|
    #	 puts attr.attrib_type.name + "\t" + attr.value
    #  end
    class TranscriptAttrib < DBConnection
      set_primary_key nil

      belongs_to :transcript
      belongs_to :attrib_type
    end

    # = DESCRIPTION
    # The DnaAlignFeature class provides an interface to the
    # dna_align_feature table. This table contains sequence similarity
    # mappings against a SeqRegion.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  unigene_scan = Analysis.find_by_logic_name('Unigene')
    #  unigene_scan.dna_align_features.each do |hit|
    #	 puts hit.seq_region.name + "\t" + hit.hit_name + "\t" + hit.cigar_line
    #  end
    class DnaAlignFeature < DBConnection
      include Sliceable

      set_primary_key 'dna_align_feature_id'

      belongs_to :seq_region
      belongs_to :analysis
      
      has_many :exon_supporting_features
      has_many :protein_supporting_features
    end

    # = DESCRIPTION
    # The Translation class provides an interface to the
    # translation table. This table contains the translation start and
    # stop positions and exons for a given Transcript
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  #TODO
    class Translation < DBConnection
      set_primary_key 'translation_id'

      belongs_to :transcript
      has_many :translation_stable_ids

      has_many :translation_attribs
      has_many :protein_features
      
      has_one :translation_stable_id
      
      has_many :object_xrefs, :foreign_key => 'ensembl_id', :conditions => "ensembl_object_type = 'Translation'"
      has_many :xrefs, :through => :object_xrefs
      
      belongs_to :start_exon, :class_name => 'Exon', :foreign_key => 'start_exon_id'
      belongs_to :end_exon, :class_name => 'Exon', :foreign_key => 'end_exon_id'

      alias attribs translation_attribs
      
      # The Translation#stable_id method returns the stable ID of the translation.
      # ---
      # *Arguments*:: none
      # *Returns*:: String
      def stable_id
      	return self.translation_stable_id.stable_id
      end

      # = DESCRIPTION
      # The Translation#display_label method returns the default name of the translation.
      def display_label
        return Xref.find(self.display_xref_id).display_label
      end
      alias :display_name :display_label
      alias :label :display_label
      alias :name :display_label

      # = DESCRIPTION
      # The Translation#find_by_stable_id class method fetches a Translation
      # object based on its stable ID (i.e. the "ENSP" accession number). If the 
      # name is not found, it returns nil.
      def self.find_by_stable_id(stable_id)
        translation_stable_id = TranslationStableId.find_by_stable_id(stable_id)
        if translation_stable_id.nil?
          return nil
        else
          return translation_stable_id.translation
        end
      end
    end

    # = DESCRIPTION
    # The TranslationStableId class provides an interface to the
    # translation_stable_id table. This table contains the Ensembl stable IDs
    # for a given Translation.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  stable_id = TranslationStableId.find_by_name('ENSBTAP00000015494')
    #  puts stable_id.to_yaml
    class TranslationStableId < DBConnection
      set_primary_key 'stable_id'

      belongs_to :translation
    end

    # = DESCRIPTION
    # The TranslationAttrib class provides an interface to the
    # translation_attrib table. This table contains attribute values for the
    # Translation class.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  translation = Translation.find(9979)
    #  translation.translation_attribs.each do |attr|
    #	 puts attr.attr_type.name + "\t" + attr.value
    #  end
    class TranslationAttrib < DBConnection
      set_primary_key nil

      belongs_to :translation
      belongs_to :attrib_type
    end

    # = DESCRIPTION
    # The Xref class provides an interface to the
    # xref table. This table contains external references for objects in the
    # database.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  gene = Gene.find(1)
    #  gene.xrefs.each do |xref|
    #	   puts xref.display_label + "\t" + xref.description
    #  end
    class Xref < DBConnection
      set_primary_key 'xref_id'

      belongs_to :external_db
      has_many :external_synonyms

      has_many :genes
      
      def to_s
        return self.external_db.db_name.to_s + ":" + self.display_label
      end
    end

    # = DESCRIPTION
    # The ObjectXref class provides the link between gene, transcript and
    # translation objects on the one hand and an xref on the other.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  gene = Gene.find(1)
    #  gene.object_xrefs.each do |ox|
    #	   puts ox.to_yaml
    #  end
    class ObjectXref < DBConnection
      set_primary_key 'object_xref_id'
      
      belongs_to :gene, :class_name => "Gene", :foreign_key => 'ensembl_id', :conditions => ["ensembl_object_type = 'Gene'"]
      belongs_to :transcript, :class_name => "Transcript", :foreign_key => 'ensembl_id', :conditions => ["ensembl_object_type = 'Transcript'"]
      belongs_to :translation, :class_name => "Translation", :foreign_key => 'ensembl_id', :conditions => ["ensembl_object_type = 'Translation'"]
      belongs_to :xref
      has_one :go_xref
    end
    
    # = DESCRIPTION
    # The GoXref class provides an interface to the
    # go_xref table. This table contains the evidence codes for those object_refs
    # that are GO terms.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class GoXref < DBConnection
      set_primary_key nil
      
      belongs_to :xref
    end

    # = DESCRIPTION
    # The ExternalDb class provides an interface to the
    # external_db table. This table contains references to databases to which
    # xrefs can point to
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  embl_db = ExternalDb.find_by_db_name('EMBL')
    #  puts embl_db.xrefs.length.to_s
    class ExternalDb < DBConnection
      set_primary_key 'external_db_id'

      has_many :xrefs

      def self.inheritance_column
        nil
      end

      # = DESCRIPTION
      # The ExternalDb#find_all_by_display_label method returns all external
      # databases that have this label. There should normally be no more than
      # one. If no databases are found with this name, this method returns an
      # empty array.
      def self.find_all_by_display_label(label)
      	answer = Array.new
        xrefs = Xref.find_all_by_display_label(label)
      	xrefs.each do |xref|
          answer.push(self.class.find_by_xref_id(xref.xref_id))
        end

        return answer
      end
      
      # = DESCRIPTION
      # The ExternalDb#find_by_display_label method returns a
      # database that has this label. If no databases are found with this name,
      # this method returns nil.
      # empty array.
      def self.find_by_display_label(label)
        all_dbs = self.find_all_by_display_label(label)
        if all_dbs.length == 0
          return nil
        else
          return all_dbs[0]
        end
      end

      
    end

    # = DESCRIPTION
    # The ExternalSynonym class provides an interface to the
    # external_synonym table. This table contains synonyms for Xref objects.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  xref = Xref.find(185185)
    #  puts xref.external_synonyms[0].synonyms
    class ExternalSynonym < DBConnection
      set_primary_key nil

      belongs_to :xref
    end

    # = DESCRIPTION
    # The Karyotype class provides an interface to the
    # karyotype table. This table contains <>.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  band = Karyotype.find_by_band('p36.32')
    #  puts band.to_yaml
    class Karyotype < DBConnection
      include Sliceable

      set_primary_key 'karyotype_id'

      belongs_to :seq_region
    end

    # = DESCRIPTION
    # The OligoFeature class provides an interface to the
    # oligo_feature table. This table contains mappings of Oligo objects to
    # a SeqRegion.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  seq_region = SeqRegion.find_by_name('4')
    #  puts seq_region.oligo_features.length
    class OligoFeature < DBConnection
      include Sliceable

      set_primary_key 'oligo_feature_id'

      belongs_to :seq_region
      belongs_to :oligo_probe
      belongs_to :analysis
    end

    # = DESCRIPTION
    # The OligoProbe class provides an interface to the
    # oligo_probe table.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  probe = OligoProbe.find_by_name('373:434;')
    #  puts probe.probeset + "\t" + probe.oligo_array.name
    class OligoProbe < DBConnection
      set_primary_key 'oligo_probe_id'

      has_many :oligo_features
      belongs_to :oligo_array
    end

    # = DESCRIPTION
    # The OligoArray class provides an interface to the
    # oligo_array table. This table contains data describing a microarray
    # slide.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  array = OligoArray.find_by_name_and_type('Bovine','AFFY')
    #  puts array.oligo_probes.length
    class OligoArray < DBConnection
      set_primary_key 'oligo_array_id'

      has_many :oligo_probes
    end

    # = DESCRIPTION
    # The PredictionExon class provides an interface to the
    # prediction_exon table. This table contains <>.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  #TODO
    class PredictionExon < DBConnection
      include Sliceable

      set_primary_key 'prediction_exon_id'

      belongs_to :prediction_transcript
      belongs_to :seq_region
    end

    # = DESCRIPTION
    # The PredictionTranscript class provides an interface to the
    # prediction_transcript table.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  predicted_transcript = PredictionTranscript.find_by_display_label('GENSCAN00000000006')
    #  puts predicted_transcript.prediction_exons.length
    class PredictionTranscript < DBConnection
      include Sliceable

      set_primary_key 'prediction_transcript_id'

      has_many :prediction_exons
      belongs_to :seq_region
      belongs_to :analysis
    end

    # = DESCRIPTION
    # The ProteinFeature class provides an interface to the
    # protein_feature table. This table contains mappings of a Translation
    # onto a SeqRegion.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  #TODO
    class ProteinFeature < DBConnection
      include Sliceable

      set_primary_key 'protein_feature_id'

      belongs_to :translation
      belongs_to :analysis
    end

    # = DESCRIPTION
    # The ProteinAlignFeature class provides an interface to the
    # protein_align_feature table. This table contains sequence similarity
    # mappings against a SeqRegion.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  uniprot_scan = Analysis.find_by_logic_name('Uniprot')
    #  uniprot_scan.protein_align_features.each do |hit|
    #	 puts hit.seq_region.name + "\t" + hit.hit_name + "\t" + hit.cigar_line
    #  end
    class ProteinAlignFeature < DBConnection
      include Sliceable

      set_primary_key 'protein_align_feature_id'

      belongs_to :seq_region
      belongs_to :analysis
      
      has_many :exon_supporting_features
      has_many :transcript_supporting_features
    end

    # = DESCRIPTION
    # The RegulatoryFactor class provides an interface to the
    # regulatory_factor table.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  factor = RegulatoryFactor.find_by_name('crtHsap8070')
    #  puts factor.to_yaml
    class RegulatoryFactor < DBConnection
      set_primary_key 'regulatory_factor_id'

      has_many :regulatory_features
    end

    # = DESCRIPTION
    # The RegulatoryFeature class provides an interface to the
    # regulatory_feature table. This table contains mappings of
    # RegulatoryFactor objects against a SeqRegion.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # = USAGE
    #  analysis = Analysis.find_by_logic_name('miRanda')
    #  analysis.regulatory_features.each do |feature|
    #	 puts feature.name + "\t" + feature.regulatory_factor.name
    #  end
    class RegulatoryFeature < DBConnection
      include Sliceable

      set_primary_key 'regulatory_feature_id'

      belongs_to :seq_region
      belongs_to :analysis
      belongs_to :regulatory_factor
    end
  end
end
