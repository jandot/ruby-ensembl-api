#
# = ensembl/core/transcript.rb - ActiveRecord mapping to Ensembl core for transcript
#
# Copyright::   Copyright (C) 2007 Jan Aerts <http://jandot.myopenid.com>
# License::     The Ruby License
#
# @author Jan Aerts
nil
module Ensembl
  nil
  module Core
    # The Intron class describes an intron.
    # 
    # This class does _not_ use ActiveRecord and is only defined within the API.
    # There is no _introns_ table in the Ensembl database.
    # 
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects o this
    # class. See Sliceable and Slice for more information.
    # 
    # @example
    #  exon1 = Ensembl::Core::Exon.find(292811)
    #  exon2 = Ensembl::Core::Exon.find(292894)
    #  intron = Ensembl::Core::Intron.new(exon1,exon2)
    #  puts intron.to_yaml
    #  
    #  transcript = Ensembl::Core::Transcript.find(58972)
    #  puts transcript.introns.to_yaml
    class Intron
      include Sliceable
      attr_accessor :seq_region, :seq_region_start, :seq_region_end, :seq_region_strand
      attr_accessor :previous_exon, :next_exon, :transcript
      
      def initialize(exon_1, exon_2)
        # Check if these are actually two adjacent exons from the same transcript
        ok = true

        transcript = nil
        exon_1.transcripts.each do |t|
          transcript = t if exon_2.transcripts.include?(t)
        end
        raise ArgumentError, "Arguments should be adjacent exons of same transcript" if transcript.nil?
        
        rank_1 = ExonTranscript.find_by_transcript_id_and_exon_id(transcript.id, exon_1.id).rank
        rank_2 = ExonTranscript.find_by_transcript_id_and_exon_id(transcript.id, exon_2.id).rank
        raise ArgumentError, "Arguments should be adjacent exons of same transcript" if (rank_2 - rank_1).abs > 1
        
        @previous_exon, @next_exon = [exon_1, exon_2].sort_by{|e| e.seq_region_start}
        @transcript = transcript
        @seq_region = @previous_exon.seq_region
        @seq_region_start = @previous_exon.seq_region_end + 1
        @seq_region_end = @next_exon.seq_region_start - 1
        @seq_region_strand = @previous_exon.seq_region_strand
      end

    end
    
    # The Transcript class provides an interface to the transcript
    # table. This table contains mappings of transcripts for a Gene to a
    # SeqRegion.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # This class includes the mixin Sliceable, which means that it is mapped
    # to a SeqRegion object and a Slice can be created for objects of this
    # class. See Sliceable and Slice for more information.
    #
    # @example
    #  #TODO
    class Transcript < DBConnection
      include Sliceable

      set_table_name 'transcript'
      set_primary_key 'transcript_id'

      belongs_to :gene
      belongs_to :seq_region
      has_one :transcript_stable_id
      has_many :transcript_attribs
      
      has_many :exon_transcripts
#      has_many :exons, :through => :exon_transcripts

      has_one :translation
      
      has_many :object_xrefs, :foreign_key => 'ensembl_id', :conditions => "ensembl_object_type = 'Transcript'"
      has_many :xrefs, :through => :object_xrefs

      has_many :transcript_supporting_features
      has_many :dna_align_features, :through => :transcript_supporting_features, :conditions => ["feature_type = 'dna_align_feature'"]
      has_many :protein_align_features, :through => :transcript_supporting_features, :conditions => ["feature_type = 'protein_align_feature'"]

      alias attribs transcript_attribs

      # The Transcript#exons method returns the exons for this transcript in
      # the order of their ranks in the exon_transcript table.
      # 
      # @return [Array<Exon>] Sorted array of Exon objects
      def exons
        if @exons.nil?
          @exons = self.exon_transcripts(:include => [:exons]).sort_by{|et| et.rank.to_i}.collect{|et| et.exon}
        end
        return @exons
      end

      # The Transcript#introns methods returns the introns for this transcript
      # 
      # @return [Array<Intron>] Sorted array of Intron objects
      def introns
        if @introns.nil?
          @introns = Array.new
          if self.exons.length > 1
            self.exons.each_with_index do |exon, index|
              next if index == 0
              @introns.push(Intron.new(self.exons[index - 1], exon))
            end
          end
        end
        return @introns
      end
      
      # The Transcript#stable_id method returns the stable ID of the transcript.
      # 
      # @return [String] Ensembl stable ID of the transcript.
      def stable_id
      	return self.transcript_stable_id.stable_id
      end

      # The Transcript#display_label method returns the default name of the transcript.
      def display_label
        return Xref.find(self.display_xref_id).display_label
      end
      alias :display_name :display_label
      alias :label :display_label
      alias :name :display_label

      # The Transcript#find_all_by_stable_id class method returns an array of
      # transcripts with the given stable_id. If none were found, an empty
      # array is returned.
      def self.find_all_by_stable_id(stable_id)
      	answer = Array.new
        transcript_stable_id_objects = Ensembl::Core::TranscriptStableId.find_all_by_stable_id(stable_id)
        transcript_stable_id_objects.each do |transcript_stable_id_object|
          answer.push(Ensembl::Core::Transcript.find(transcript_stable_id_object.transcript_id))
        end
      
      	return answer
      end
      
      # The Transcript#find_all_by_stable_id class method returns a
      # transcripts with the given stable_id. If none was found, nil is returned.
      def self.find_by_stable_id(stable_id)
        all = self.find_all_by_stable_id(stable_id)
        if all.length == 0
          return nil
        else
          return all[0]
        end
      end
      
      # The Transcript#find_by_stable_id class method fetches a Transcript object based on
      # its stable ID (i.e. the "ENST" accession number). If the name is
      # not found, it returns nil.
      def self.find_by_stable_id(stable_id)
        transcript_stable_id = TranscriptStableId.find_by_stable_id(stable_id)
        if transcript_stable_id.nil?
          return nil
        else
          return transcript_stable_id.transcript
        end
      end
      
      # The Transcript#seq method returns the full sequence of all concatenated
      # exons.
      def seq
        if @seq.nil?
          @seq = ''
          self.exons.each do |exon|
            @seq += exon.seq
          end
        end
        return @seq
      end

      # The Transcript#cds_seq method returns the coding sequence of the transcript,
      # i.e. the concatenated sequence of all exons minus the UTRs.
      def cds_seq
        cds_length = self.coding_region_cdna_end - self.coding_region_cdna_start + 1
        
        return self.seq[(self.coding_region_cdna_start - 1), cds_length]
      end
      
      # The Transcript#five_prime_utr_seq method returns the sequence of the
      # 5'UTR of the transcript.
      def five_prime_utr_seq
        return self.seq[0, self.coding_region_cdna_start - 1]
      end

      # The Transcript#three_prime_utr_seq method returns the sequence of the
      # 3'UTR of the transcript.
      def three_prime_utr_seq
        return self.seq[self.coding_region_cdna_end..-1]
      end

      # The Transcript#protein_seq method returns the sequence of the
      # protein of the transcript.
      def protein_seq
        return Bio::Sequence::NA.new(self.cds_seq).translate.seq
      end


      # The Transcript#coding_region_genomic_start returns the start position
      # of the CDS in genomic coordinates. Note that, in contrast to
      # Transcript#coding_region_cdna_start, the CDS start position is _always_
      # ''left'' of the end position. So for transcripts on the reverse strand,
      # the CDS start position is at the border of the 3'UTR instead of the
      # 5'UTR.
      def coding_region_genomic_start
        strand = self.translation.start_exon.seq_region_strand
        if strand == 1
          return self.translation.start_exon.seq_region_start + ( self.translation.seq_start - 1 )
        else
          return self.translation.end_exon.seq_region_end - ( self.translation.seq_end - 1 )
        end
      end

      # The Transcript#coding_region_genomic_end returns the stop position
      # of the CDS in genomic coordinates. Note that, in contrast to
      # Transcript#coding_region_cdna_end, the CDS stop position is _always_
      # ''right'' of the start position. So for transcripts on the reverse strand,
      # the CDS stop position is at the border of the 5'UTR instead of the
      # 3'UTR.
      def coding_region_genomic_end
        strand = self.translation.start_exon.seq_region_strand
        if strand == 1
          return self.translation.end_exon.seq_region_start + ( self.translation.seq_end - 1 )
        else
          return self.translation.start_exon.seq_region_end - ( self.translation.seq_start - 1 )
        end
      end
      
      # The Transcript#coding_region_cdna_start returns the start position
      # of the CDS in cDNA coordinates. Note that, in contrast to the
      # Transcript#coding_region_genomic_start, the CDS start position is
      # _always_ at the border of the 5'UTR. So for genes on the reverse
      # strand, the CDS start position in cDNA coordinates will be ''right''
      # of the CDS stop position.
      def coding_region_cdna_start
        answer = 0
        
        self.exons.each do |exon|
          if exon == self.translation.start_exon
            answer += self.translation.seq_start
            return answer
          else
            answer += exon.length
          end
        end
        
      end
      
      # The Transcript#coding_region_cdna_end returns the stop position
      # of the CDS in cDNA coordinates. Note that, in contrast to the
      # Transcript#coding_region_genomic_end, the CDS start position is
      # _always_ at the border of the 3'UTR. So for genes on the reverse
      # strand, the CDS start position in cDNA coordinates will be ''right''
      # of the CDS stop position.
      def coding_region_cdna_end
        answer = 0
        
        self.exons.each do |exon|
          if exon == self.translation.end_exon
            answer += self.translation.seq_end
            return answer
          else
            answer += exon.length
          end
        end
      end


      # The Transcript#exon_for_position identifies the exon that covers a given
      # genomic position. Returns the exon object, or nil if in intron.
      def exon_for_genomic_position(pos)
        if pos < coding_region_genomic_start or pos > coding_region_genomic_end
          raise RuntimeError, "Position has to be within transcript"
        end
        self.exons.each do |exon|
          if exon.start <= pos and exon.stop >= pos
            return exon
          end
        end
        return nil
      end

      # The Transcript#exon_for_position identifies the exon that covers a given
      # position of the cDNA.
      def exon_for_cdna_position(pos)
        # FIXME: Still have to check for when pos is outside of scope of cDNA.
        accumulated_exon_length = 0
        
        self.exons.each do |exon|
          accumulated_exon_length += exon.length
          if accumulated_exon_length > pos
            return exon
          end
        end
        raise RuntimeError, "Position outside of cDNA scope"
      end

      # The Transcript#cdna2genomic method converts cDNA coordinates to
      # genomic coordinates for this transcript.
      # 
      # @param [Integer] pos Position on the cDNA
      # @return [Integer] Position on the genomic DNA
      def cdna2genomic(pos)
        #FIXME: Still have to check for when pos is outside of scope of cDNA.
        # Identify the exon we're looking at.
        exon_with_target = self.exon_for_cdna_position(pos)
        
        accumulated_position = 0
        self.exons.each do |exon|
          if exon == exon_with_target
            answer = exon.start + ( pos - accumulated_position )
            return answer
          else
            accumulated_position += exon.length
          end
        end
      end
      
      # The Transcript#cds2genomic method converts CDS coordinates to
      # genomic coordinates for this transcript.
      # 
      # @param [Integer] pos Position on the CDS
      # @return [Integer] Position on the genomic DNA
      def cds2genomic(pos)
        return self.cdna2genomic(pos + self.coding_region_cdna_start)
      end
      
      # The Transcript#pep2genomic method converts peptide coordinates to
      # genomic coordinates for this transcript.
      # 
      # @param [Integer] pos Aminoacid position on the protein
      # @return [Integer] Position on the genomic DNA
      def pep2genomic(pos)
        raise NotImplementedError
      end

      # The Transcript#genomic2cdna method converts genomic coordinates to
      # cDNA coordinates for this transcript.
      # 
      # @param [Integer] pos Position on the genomic DNA
      # @return [Integer] Position on the cDNA
      def genomic2cdna(pos)
        #FIXME: Still have to check for when pos is outside of scope of cDNA.
        # Identify the exon we're looking at.
        exon_with_target = self.exon_for_genomic_position(pos)
        
        accumulated_position = 0
        self.exons.each do |exon|
          if exon == exon_with_target
            accumulated_position += ( pos - exon.start )
            return accumulated_position
          else
            accumulated_position += exon.length
          end
        end
        return RuntimeError, "Position outside of cDNA scope"
      end

      # The Transcript#genomic2cds method converts genomic coordinates to
      # CDS coordinates for this transcript.
      # 
      # @param [Integer] pos Position on the genomic DNA
      # @return [Integer] Position on the CDS
      def genomic2cds(pos)
        return self.genomic2cdna(pos) - self.coding_region_cdna_start
      end

      # The Transcript#genomic2pep method converts genomic coordinates to
      # peptide coordinates for this transcript.
      # 
      # @param [Integer] pos Base position on the genomic DNA
      # @return [Integer] Aminoacid position in the protein
      # *Arguments*:
      # * pos:: position on the chromosome (required)
      # *Returns*:: 
      def genomic2pep(pos)
        raise NotImplementedError
      end

    end
  end
end
