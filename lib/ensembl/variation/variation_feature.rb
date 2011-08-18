#
# = ensembl/variation/variation.rb - Extension of ActiveRecord classes for Ensembl variation features
#
# Copyright::   Copyright (C) 2008 Francesco Strozzi <francesco.strozzi@gmail.com>
# License::     The Ruby License
#
# @author Francesco Strozzi


module Ensembl

  module Variation
    
    
    # The VariationFeature class gives information about the genomic position of 
    # each Variation, including also validation status and consequence type. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # @example
    #   # SLOWER QUERY
    #   vf = VariationFeature.find_by_variation_name('rs10111')
    #   # FASTER QUERY
    #   vf = Variation.find_by_name('rs10111').variation_feature
    #   
    #   puts vf.seq_region_start, vf.seq_region_end, vf.allele_string
    #   puts vf.variation.ancestral_allele
    #   genomic_region = vf.fetch_region (returns an Ensembl::Core::Slice)
    #   genomic_region.genes
    #   up_region,down_region = vf.flanking_seq (returns two Ensembl::Core::Slice)
    #
    class VariationFeature < DBConnection
      set_primary_key "variation_feature_id"
      belongs_to :variation
      has_many :tagged_variation_features
      has_many :samples, :through => :tagged_variation_features
      belongs_to :seq_region
      validates_inclusion_of :consequence_type, :in => ['ESSENTIAL_SPLICE_SITE',
                                                        'STOP_GAINED',
                                                        'STOP_LOST',
                                                        'COMPLEX_INDEL',
                                                        'FRAMESHIFT_CODING',
                                                        'NON_SYNONYMOUS_CODING',
                                                        'SPLICE_SITE',
                                                        'PARTIAL_CODON',
                                                        'SYNONYMOUS_CODING',
                                                        'REGULATORY_REGION',
                                                        'WITHIN_MATURE_miRNA',
                                                        '5PRIME_UTR',
                                                        '3PRIME_UTR',
                                                        'INTRONIC',
                                                        'NMD_TRANSCRIPT',
                                                        'UPSTREAM',
                                                        'DOWNSTREAM',
                                                        'WITHIN_NON_CODING_GENE',
                                                        'HGMD_MUTATION'
                                                        ], :message => "Consequence type not allowed!"      
      
      def consequence_type # workaround as ActiveRecord do not parse SET field in MySQL
        "#{attributes_before_type_cast['consequence_type']}" 
      end 
      
      # Based on Perl API 'get_all_Genes' method for Variation class. Get a genomic region
      # starting from the Variation coordinates, expanding the region upstream and
      # downstream.
      #
      # @param [Integer] up Length of upstream flanking region
      # @param [Integer] down Length of downstream flanking region
      # @return [Slice] Slice object containing the variation
      def fetch_region(up = 5000, down = 5000)
        sr = core_connection(self.seq_region_id)
        slice = Ensembl::Core::Slice.fetch_by_region(Ensembl::Core::CoordSystem.find(sr.coord_system_id).name,sr.name,self.seq_region_start-up,self.seq_region_end+down)
        return slice
      end
      
      def flanking_seq
        sr = core_connection(self.seq_region_id)
        f = Variation.find(self.variation_id).flanking_sequence
        slice_up = Ensembl::Core::Slice.fetch_by_region(Ensembl::Core::CoordSystem.find(sr.coord_system_id).name,sr.name,f.up_seq_region_start,f.up_seq_region_end,self.seq_region_strand)
        slice_down = Ensembl::Core::Slice.fetch_by_region(Ensembl::Core::CoordSystem.find(sr.coord_system_id).name,sr.name,f.down_seq_region_start,f.down_seq_region_end,self.seq_region_strand)
        return slice_up,slice_down
      end
      
      def transcript_variations
        tvs = TranscriptVariation.find_all_by_variation_feature_id(self.variation_feature_id)
        if tvs[0].nil? then # the variation is not stored in the database, so run the calculations
          sr = core_connection(self.seq_region_id)
          return custom_transcript_variation(self,sr)
        else
          return tvs # the variation is already present in the database
        end  
      end
      
      private 
      
      def core_connection(seq_region_id) 
        if !Ensembl::Core::DBConnection.connected? then  
          host,user,password,db_name,port,species,release = Ensembl::Variation::DBConnection.get_info
          begin
            Ensembl::Core::DBConnection.connect(species,release.to_i,:username => user, :password => password,:host => host, :port => port)
          rescue
            raise NameError, "Can't derive Core database name from #{db_name}. Are you using non conventional names?"
          end
        end
        # Check if SeqRegion already exists in Ensembl::SESSION
        seq_region = nil
        if Ensembl::SESSION.seq_regions.has_key?(seq_region_id)
          seq_region = Ensembl::SESSION.seq_regions[seq_region_id]
        else
          seq_region = Ensembl::Core::SeqRegion.find(seq_region_id)
          Ensembl::SESSION.seq_regions[seq_region.id] = seq_region
        end
        return seq_region
      end
      
      # Calculate a consequence type for a user-defined variation
      def custom_transcript_variation(vf,sr)
                
        @variation_name = vf.variation_name
        @seq_region = sr

        downstream = 5000
        upstream = 5000
        tvs = [] # store all the calculated TranscriptVariations
         # retrieve the slice of the genomic region where the variation is located
         region = Ensembl::Core::Slice.fetch_by_region(Ensembl::Core::CoordSystem.find(sr.coord_system_id).name,sr.name,vf.seq_region_start-upstream,vf.seq_region_end+downstream-1)
         # iterate through all the transcripts present in the region
        genes = region.genes(inclusive = true)
         if genes[0] != nil
          genes.each do |g|
            g.transcripts.each do |t|
              @cache = {}
              tv = TranscriptVariation.new() # create a new TranscriptVariation object for every transcript present
              # do the calculations
              
              # check if the variation is intergenic for this transcript (no effects)
              tv.consequence_type = check_intergenic(vf,t)
              
              # check if the variation is upstram or downstram the transcript
              tv.consequence_type = check_upstream_downstream(vf,t) if tv.consequence_type == ""
              
              # if no consequence type is found, then the variation is inside the transcript         
              # check for non coding gene
              tv.consequence_type = check_non_coding(vf,t) if tv.consequence_type == "" and t.biotype != 'protein_coding'

              # if no consequence type is found, then check intron / exon boundaries
              tv.consequence_type = check_splice_site(vf,t) if tv.consequence_type == ""

              # if no consequence type is found, check if the variation is inside UTRs
              tv.consequence_type = check_utr(vf,t) if tv.consequence_type == ""    
                        
              # if no consequence type is found, then variation is inside an exon. 
              # Check the codon change
              (tv.consequence_type,tv.peptide_allele_string) = check_aa_change(vf,t) if tv.consequence_type == ""
                
              
              begin # this changed from release 58
                 tv.transcript_stable_id = t.stable_id
              rescue NoMethodError
                 tv.transcript_id = t.id
              end
              
              tv.consequence_type = "INTERGENIC" if tv.consequence_type == ""
              tvs << tv 
            end   
          end
         end
         # if there are no transcripts/genes within 5000 bases upstream and downstream set the variation as INTERGENIC (no effects)
         if tvs.size == 0 then
          tv = TranscriptVariation.new()
          tv.consequence_type = "INTERGENIC"
          tvs << tv
         end

         return tvs
       end
      
      ## CONSEQUENCE CALCULATION FUNCTIONS ##
      
      def check_intergenic(vf,t)
        if vf.seq_region_end < t.seq_region_start and (t.seq_region_start - vf.seq_region_end) > 5000 then
           return "INTERGENIC"
        elsif vf.seq_region_start > t.seq_region_end and (vf.seq_region_start - t.seq_region_end) > 5000 then
           return "INTERGENIC"      
        end
        return nil        
      end
      
      def check_upstream_downstream(vf,t)
        if vf.seq_region_end < t.seq_region_start and (t.seq_region_start - vf.seq_region_end) <= 5000 then
           return (t.strand == 1) ? "UPSTREAM" : "DOWNSTREAM"
        elsif vf.seq_region_start > t.seq_region_end and (vf.seq_region_start - t.seq_region_end) <= 5000 then
           return (t.strand == 1) ? "DOWNSTREAM" : "UPSTREAM"
        
        # check if it's an InDel and if overlaps the transcript start / end   
        elsif t.seq_region_start > vf.seq_region_start and t.seq_region_start < vf.seq_region_end then
            return "COMPLEX_INDEL"
        elsif t.seq_region_end > vf.seq_region_start and t.seq_region_end < vf.seq_region_end then
            return "COMPLEX_INDEL"                
        end
        return nil
      end
      
      def check_non_coding(vf,t)
          if t.biotype == "miRNA" then 
             return (vf.seq_region_start == vf.seq_region_end) ? "WITHIN_MATURE_miRNA" : "COMPLEX_INDEL"
          elsif t.biotype == "nonsense_mediated_decay"
             return (vf.seq_region_start == vf.seq_region_end) ? "NMD_TRANSCRIPT" : "COMPLEX_INDEL"
          else
             return (vf.seq_region_start == vf.seq_region_end) ? "WITHIN_NON_CODING_GENE" : "COMPLEX_INDEL"
          end
          return nil
      end
      
      def check_utr(vf,t)
          if vf.seq_region_start > t.seq_region_start and vf.seq_region_end < t.coding_region_genomic_start then
             return (t.strand == 1) ? "5PRIME_UTR" : "3PRIME_UTR"
          elsif vf.seq_region_start > t.coding_region_genomic_end and vf.seq_region_end < t.seq_region_end then
             return (t.strand == 1) ? "3PRIME_UTR" : "5PRIME_UTR"   
          end
          return nil   
      end
      
      def check_splice_site(vf,t)
        @cache[:exons] = []
        var_start,var_end = (vf.seq_region_strand == 1) ? [vf.seq_region_start,vf.seq_region_end] : [vf.seq_region_end,vf.seq_region_start]
        t.exons.each {|ex| @cache[:exons] << Range.new(ex.seq_region_start,ex.seq_region_end)}
        
        exon_up = check_near_exons(var_start,@cache[:exons])
        exon_down = check_near_exons(var_end,@cache[:exons])
        if !exon_up and !exon_down # we are inside an intron
           # checking boundaries
           near_exon_up_2bp = check_near_exons(var_start-2..var_start,@cache[:exons])
           near_exon_down_2bp = check_near_exons(var_end..var_end+2,@cache[:exons])
           if near_exon_up_2bp or near_exon_down_2bp then
              return "ESSENTIAL_SPLICE_SITE"
           else
              near_exon_up_8bp = check_near_exons(var_start+8..var_start,@cache[:exons])
              near_exon_down_8bp = check_near_exons(var_end..var_end+8,@cache[:exons])    
              if near_exon_up_8bp or near_exon_down_8bp then
                 return "SPLICE_SITE"
              else
                 return "INTRONIC"   
              end
           end
        elsif exon_up and exon_down # the variation is inside an exon
             # check if it is a splice site
             if (var_start-exon_up.first) <= 3 or (exon_down.last-var_end) <= 3 then
                return "SPLICE_SITE"                   
             end
        else # a complex indel spanning intron/exon boundary
             return "COMPLEX_INDEL"
        end
        return nil      
      end
      
      def check_aa_change(vf,t)
          alleles = vf.allele_string.split('/') # get the different alleles for this variation          
          # if the variation is an InDel then it produces a frameshift
          if vf.seq_region_start != vf.seq_region_end or alleles.include?("-") then
            return "FRAMESHIFT_CODING",nil
          end

          # Find the position inside the CDS
          
          mutation_position = t.genomic2cds(vf.seq_region_start)
          
          mutation_base = Bio::Sequence::NA.new(alleles[1])
          if t.seq_region_strand == -1
             mutation_base.reverse_complement!
          end
          # The rank of the codon 
          target_codon = (mutation_position)/3 + 1
          cds_sequence = nil
          cds_sequence = t.cds_seq
          mut_sequence = cds_sequence.dup
          # Replace base with the variant allele
          mut_sequence[mutation_position] = mutation_base.seq
          refcodon =  cds_sequence[(target_codon*3 -3)..(target_codon*3-1)]
          mutcodon =  mut_sequence[(target_codon*3 -3)..(target_codon*3-1)]
          codontable = Bio::CodonTable[1]
          refaa = codontable[refcodon]
          mutaa = codontable[mutcodon.downcase]
          if mutaa == nil
            raise RuntimeError "Codon #{mutcodon.downcase} wasn't recognized."
          end
          pep_string = refaa+"/"+mutaa
          if mutaa == "*" and refaa != "*"
            return "STOP_GAINED",pep_string
          elsif mutaa != "*" and refaa == "*"
            return "STOP_LOST",pep_string
          elsif mutaa != refaa
            return "NON_SYNONYMOUS_CODING",pep_string 
          elsif mutaa == refaa
            return "SYNONYMOUS_CODING",pep_string 
          end
           
       end
       
       
       def check_near_exons(feature,exons_ranges)
        exons_ranges.each do |exon_range|
          if feature.is_a? Range
            return exon_range if (feature.first <= exon_range.last) && (exon_range.first <= feature.last)
          else
            return exon_range if exon_range.include? feature
          end  
        end
        return false
       end
      
      
    end # VariationFeature
    
    # The TranscriptVariation class gives information about the position of 
    # a VariationFeature, mapped on an annotated transcript.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # @example 
    #   vf = Variation.find_by_name('rs10111').variation_feature
    #   vf.transcript_variations.each do |tv|
    #     puts tv.peptide_allele_string, tv.transcript.stable_id    
    #   end
    #
    class TranscriptVariation < DBConnection
      set_primary_key "transcript_variation_id"
      belongs_to :variation_feature
      validates_inclusion_of :consequence_type, :in => ['ESSENTIAL_SPLICE_SITE',
                                                        'STOP_GAINED',
                                                        'STOP_LOST',
                                                        'COMPLEX_INDEL',
                                                        'FRAMESHIFT_CODING',
                                                        'NON_SYNONYMOUS_CODING',
                                                        'SPLICE_SITE',
                                                        'PARTIAL_CODON',
                                                        'SYNONYMOUS_CODING',
                                                        'REGULATORY_REGION',
                                                        'WITHIN_MATURE_miRNA',
                                                        '5PRIME_UTR',
                                                        '3PRIME_UTR',
                                                        'INTRONIC',
                                                        'NMD_TRANSCRIPT',
                                                        'UPSTREAM',
                                                        'DOWNSTREAM',
                                                        'WITHIN_NON_CODING_GENE',
                                                        'HGMD_MUTATION'
                                                        ], :message => "Consequence type not allowed!"
                                                        
      def consequence_type # workaround as ActiveRecord do not parse SET field in MySQL
        "#{attributes_before_type_cast['consequence_type']}" 
      end                                                  
      
      def transcript
        host,user,password,db_name,port,species,release = Ensembl::Variation::DBConnection.get_info
        if !Ensembl::Core::DBConnection.connected? then     
            Ensembl::Core::DBConnection.connect(species,release.to_i,:username => user, :password => password,:host => host, :port => port)    
        end
        
        begin # this changed from release 58
          return Ensembl::Core::Transcript.find_by_stable_id(self.transcript_stable_id)
        rescue NoMethodError  
          return Ensembl::Core::Transcript.find(self.transcript_id)
        end
        
      end
      
    end
    
  end
  
end
