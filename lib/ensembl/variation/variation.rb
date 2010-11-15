#
# = ensembl/variation/variation.rb - Extension of ActiveRecord classes for Ensembl variation features
#
# Copyright::   Copyright (C) 2008 Francesco Strozzi <francesco.strozzi@gmail.com>
# License::     The Ruby License
#


module Ensembl
  
  module Variation
    
    # = DESCRIPTION
    # The Variation class represents single nucleotide polymorhisms (SNP) or variations 
    # and provides information like the names (IDs), the validation status and 
    # the allele information.
    #
    # *BUG*: fields like validation_status and consequence_type are created 
    # using SET option directly in MySQL. These fields are bad interpreted by
    # ActiveRecord, returning always 0.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    #= USAGE
    # v = Variation.find_by_name('rs10111')
    # v.alleles.each do |a|
    #  puts a.allele, a.frequency
    # end
    #
    # variations = Variation.fetch_all_by_source('dbSNP') (many records)
    # variations.each do |v|
    #   puts v.name
    # end
    # 
    class Variation < DBConnection
      set_primary_key "variation_id"
      belongs_to :source
      has_many :variation_synonyms
      has_one :flanking_sequence
      has_many :allele_group_alleles
      has_many :allele_groups, :through => :allele_group_alleles
      has_many :population_genotypes
      has_many :alleles
      has_many :variation_features
      has_many :variation_group_variations
      has_many :variation_groups, :through => :variation_group_variations
      has_many :individual_genotype_multiple_bps
      
      def self.fetch_all_by_source(source)
        variations = Source.find_by_name(source).variations
      end
    end
    
    
    # = DESCRIPTION
    # The VariationFeature class gives information about the genomic position of 
    # each Variation, including also validation status and consequence type. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    #= USAGE
    # * SLOWER QUERY*
    # vf = VariationFeature.find_by_variation_name('rs10111')
    # * FASTER QUERY*
    # vf = Variation.find_by_name('rs10111').variation_feature
    #
    # puts vf.seq_region_start, vf.seq_region_end, vf.allele_string
    # puts vf.variation.ancestral_allele
    # genomic_region = vf.fetch_region (returns an Ensembl::Core::Slice)
    # genomic_region.genes
    # up_region,down_region = vf.flanking_seq (returns two Ensembl::Core::Slice)
    #
    class VariationFeature < DBConnection
      set_primary_key "variation_feature_id"
      belongs_to :variation
      has_many :tagged_variation_features
      has_many :samples, :through => :tagged_variation_features
      #=DESCRIPTION
      # Based on Perl API 'get_all_Genes' method for Variation class. Get a genomic region
      # starting from the Variation coordinates, expanding the region upstream and
      # downstream. Default values are -5000 and +5000.
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
          host,user,password,db_name,port = Ensembl::Variation::DBConnection.get_info
          if db_name =~/(\w+_\w+)_\w+_(\d+)_\S+/ then
            species,release = $1,$2
            Ensembl::Core::DBConnection.connect(species,release.to_i,:username => user, :password => password,:host => host, :port => port)
          else
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
        genes = region.genes
        if genes[0] != nil
          transcripts.each do |t|
            tv = TranscriptVariation.new() # create a new TranscriptVariation object for every transcript present
            tv.transcript_stable_id = t.stable_id

            # do the calculations
            
            # check if the variation is outside the transcript
            if vf.seq_region_end < t.seq_region_start then
              tv.consequence_type = (t.strand == 1) ? "UPSTREAM" : "DOWNSTREAM"
            elsif vf.seq_region_start > t.seq_region_end then
              tv.consequence_type = (t.strand == 1) ? "DOWNSTREAM" : "UPSTREAM"
            elsif vf.seq_region_start >= t.seq_region_start and vf.seq_region_end < t.seq_region_end then
                # within transcript
              if t.biotype != 'protein_coding': # not a coding gene
                  if t.biotype == "miRNA" then 
                    tv.consequence_type = "WITHIN_MATURE_miRNA"
                  elsif t.biotype == "nonsense_mediated_decay"
                    tv.consequence_type = "NMD_TRANSCRIPT"
                  else
                    tv.consequence_type = "WITHIN_NON_CODING_GENE"
                  end
              else
                if vf.seq_region_start > t.seq_region_start and vf.seq_region_end < t.coding_region_genomic_start then
                  tv.consequence_type = (t.strand == 1) ? "5PRIME_UTR" : "3PRIME_UTR"  
                elsif vf.seq_region_start > t.coding_region_genomic_end and vf.seq_region_end < t.seq_region_end then
                  tv.consequence_type = (t.strand == 1) ? "3PRIME_UTR" : "5PRIME_UTR"
              end          
                  
                  
                

            
            tvs << tv
          end
        end
        
        # if there are no transcripts within 5000 bases upstream and downstream set the variation as INTERGENIC (no effect on any transcript)
        if tvs.size == 0 then
          tv = TranscriptVariation.new()
          tv.consequence_type = "INTERGENIC"
          tvs << tv
        end

        return tvs
      end
      
    end # VariationFeature
    
    #= DESCRIPTION
    # The TranscriptVariation class gives information about the position of 
    # a VariationFeature, mapped on an annotated transcript.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    #= USAGE 
    # vf = Variation.find_by_name('rs10111').variation_feature
    # vf.transcript_variations.each do |tv|
    #   puts tv.peptide_allele_string, tv.transcript.stable_id    
    # end
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
        if !Ensembl::Core::DBConnection.connected? then
          host,user,password,db_name,port = Ensembl::Variation::DBConnection.get_info
          if db_name =~/(\w+_\w+)_\w+_(\d+)_\S+/ then
            species,release = $1,$2
            Ensembl::Core::DBConnection.connect(species,release.to_i,:username => user, :password => password,:host => host, :port => port)
          else
            raise NameError, "Can't get Core database name from #{db_name}. Pheraps you are using non conventional names"
          end
        end
        Ensembl::Core::Transcript.find(self.transcript_id)
      end
      
    end
    
  end
  
end