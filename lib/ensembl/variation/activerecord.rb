#
# = ensembl/variation/activerecord.rb - ActiveRecord mappings to Ensembl Variation
#
# Copyright::   Copyright (C) 2008 Francesco Strozzi <francesco.strozzi@gmail.com>
# License::     The Ruby License
#
# @author Francesco Strozzi

nil
module Ensembl
  # The Ensembl::Variation module covers the variation databases from
  # ensembldb.ensembl.org.
  module Variation
    # The Allele class describes a single allele of a variation. In addition to
    # the nucleotide(s) (or absence of) that representing the allele frequency
    # and population information may be present.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # @example
    #  allele = Allele.find(1)
    #  puts allele.to_yaml
    class Allele < DBConnection
      self.primary_key = 'allele_id'
      belongs_to :sample
      belongs_to :variation
      belongs_to :population
      belongs_to :subsnp_handle
    end

    # The AlleleGroup class represents a grouping of alleles that have tight 
    # linkage and are usually present together. This is commonly known as a 
    # Haplotype or Haplotype Block. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # @example
    #  allele_group = AlleleGroup.find(1)
    #  puts allele_group.to_yaml
    class AlleleGroup < DBConnection
      self.primary_key = 'allele_group_id'
      belongs_to :variation_group
      belongs_to :source
      belongs_to :sample
      belongs_to :allele_group_allele
    end
    
    # The AlleleGroupAllele class represents a connection class between Allele and AlleleGroup. 
    # Should not be used directly.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class AlleleGroupAllele < DBConnection
      belongs_to :variation
      belongs_to :allele_group
    end
    
    # Store information on attributes types
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class AttribType < DBConnection
      self.primary_key = "attrib_type_id"
    end 
    
    # Store information on associated studies
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class AssociateStudy < DBConnection
      self.primary_key = "study1_id"
      belongs_to :study
    end
    
    
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class ConsequenceMapping < DBConnection
      
    end

    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class FailedDescription < DBConnection
      self.primary_key = "failed_description_id"
      has_many :failed_variations
    end
    
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class FailedVariation < DBConnection
      self.primary_key = "failed_variation_id"
      belongs_to :failed_description
      belongs_to :variation
    end    
    
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class FeatureType < DBConnection
      self.primary_key = "feature_type_id"
    end
        
    class Meta < DBConnection
      self.primary_key = "meta_id"
    end
    
    class MetaCoord < DBConnection
     
    end
    
    class Phenotype < DBConnection
      self.primary_key = "phenotype_id"
      has_many :variation_annotations
    end
    
    # The Sample class gives information about the biological samples stored in the database. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class Sample < DBConnection
      self.primary_key = "sample_id"
      has_one :individual
      has_one :sample_synonym
      has_many :individual_genotype_multiple_bp
      has_many :compressed_genotype_single_bp
      has_many :read_coverage
      has_one :population
      has_many :tagged_variation_features
    end

    # The IndividualPopulation class is used to connect Individual and Population classes. 
    # Should not be used directly.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class IndividualPopulation < DBConnection
      belongs_to :individual, :foreign_key => "individual_sample_id"
      belongs_to :population, :foreign_key => "population_sample_id"
    end
    
    # The Individual class gives information on the single individuals used 
    # to retrieve one or more biological samples.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class Individual < DBConnection
      self.primary_key = "sample_id"
      belongs_to :sample
      has_one :individual_type
      has_many :individual_populations, :foreign_key => "individual_sample_id"
      has_many :populations, :through => :individual_populations
    end
    
    class IndividualGenotypeMultipleBp < DBConnection
      belongs_to :sample
      belongs_to :variation
      belongs_to :subsnp_handle
    end
   
    class IndividualType < DBConnection
      self.primary_key = "invidual_type_id"
      belongs_to :individual
    end    
    
    
    class CompressedGenotypeSingleBp < DBConnection
      belongs_to :population_genotype, :foreign_key => "sample_id"
    end  
    
    class ReadCoverage < DBConnection
      belongs_to :sample
    end
    
    class Population < DBConnection
      belongs_to :sample
      self.primary_key = "sample_id"
      has_many :population_genotypes, :foreign_key => "sample_id"
      has_many :individual_populations, :foreign_key => "population_sample_id"
      has_many :individuals, :through => :individual_populations
      has_many :sample_synonyms
      has_one :population_structure
      has_many :tagged_variation_features
      has_many :alleles
      has_many :allele_groups
    end
    
    
    # The PopulationStructure class gives information on super and sub populations
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class PopulationStructure < DBConnection
      
    end
    
    # The PopulationGenotype class gives information about alleles and allele 
    # frequencies for a SNP observed within a population or a group of samples. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class PopulationGenotype < DBConnection
      self.primary_key = "population_genotype_id"
      belongs_to :variation
      belongs_to :population
      belongs_to :subsnp_handle
      has_many :compressed_genotype_single_bps, :foreign_key => "sample_id"
    end
    
    # The ProteinInfo class gives information about protein translated from a given transcript. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class ProteinInfo < DBConnection
      self.primary_key = "protein_info_id"
      belongs_to :transcript_variation
      has_many :protein_positions
    end
    
    # The PolyphenPrediction class gives information about variations effect predictions within an aminoacidic sequence 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class PolyphenPrediction < DBConnection
      self.primary_key = "polyphen_prediction_id"
      belongs_to :protein_position
    end  
    
    # The ProteinPosition class gives information about variations within an aminoacidic sequence. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class ProteinPosition < DBConnection
      self.primary_key = "protein_position_id"
      belongs_to :protein_info
      has_many :polyphen_predictions
      has_many :sift_predictions
    end
    
    
    
    # The SampleSynonym class represents information about alternative names 
    # for sample entries. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class SampleSynonym < DBConnection
      self.primary_key = "sample_synonym_id"
      belongs_to :source
      belongs_to :sample
      belongs_to :population
    end
    
    # The Source class gives information on the different databases and SNP 
    # panels used to retrieve the data
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class Source < DBConnection
      self.primary_key = "source_id"
      has_many :sample_synonyms
      has_many :allele_groups
      has_many :variations
      has_many :variation_groups
      has_many :httags
      has_many :variation_synonyms
      has_many :variation_annotations
      has_many :structural_variations
      
      def somatic_status # workaround as ActiveRecord do not parse SET field in MySQL
        "#{attributes_before_type_cast['somatic_status']}" 
      end
      
    end

    # The StructuralVariation class gives information on structural variations mapped on the genome
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class StructuralVariation < DBConnection
      self.primary_key = "structural_variation_id"
      belongs_to :source
      belongs_to :seq_region
      has_many :supporting_structural_variations
      
      class << self # Workaround for 'class' field, otherwise it creates a mess for AR
        def instance_method_already_implemented?(method_name)
          return true if method_name == 'class'
          super
        end
      end
      
      def sv_class
        self.attributes["class"]
      end
      
    end
    
        
    class SeqRegion < DBConnection
      self.primary_key = "seq_region_id"
      has_many :variation_features
      has_many :structural_variations
    end
    
    # The SubsnpHandle class gives information on SNP Submitters
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class SupportingStructuralVariation < DBConnection
      self.primary_key = "supporting_structural_variation_id"
      belongs_to :structural_variation
    end
    
    # The SubsnpHandle class gives information on SNP Submitters
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class SubsnpHandle < DBConnection
      self.primary_key = "subsnp_id"
      has_many :individual_genotype_multiple_bps, :foreign_key => "subsnp_id"
      has_many :population_genotypes, :foreign_key => "subsnp_id"
      has_many :alleles, :foreign_key => "subsnp_id"
      has_many :variation_synonyms,:foreign_key => "subsnp_id"
    end
    
    # The SiftPrediction class gives information about variations effect predictions within an aminoacidic sequence
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class SiftPrediction < DBConnection
      self.primary_key = "sift_prediction_id"
      belongs_to :protein_position
    end
    
    # The Study class gives information about studies producing variations information
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class Study < DBConnection
      self.primary_key = "study_id"
      has_many :associate_studies, :foreign_key => "study1_id"
      has_many :structural_variations
      has_many :variation_annotations
      
      def study_type
        "#{attributes_before_type_cast['study_type']}"
      end
      
    end


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
    # @example
    #   v = Variation.find_by_name('rs10111')
    #   v.alleles.each do |a|
    #     puts a.allele, a.frequency
    #   end
    #
    #   variations = Variation.fetch_all_by_source('dbSNP') # many records
    #   variations.each do |v|
    #     puts v.name
    #   end
    # 
    class Variation < DBConnection
      self.primary_key = "variation_id"
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
      has_many :failed_variations
      has_many :failed_descriptions, :through => :failed_variations
      has_many :variation_set_variations
      has_many :variation_sets, :through => :variation_set_variations

      def self.fetch_all_by_source(source)
        variations = Source.find_by_name(source).variations
      end
    end
    
    # The VariationSynonym class gives information on alterative names used 
    # for Variation entries. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class VariationSynonym < DBConnection
      self.primary_key = "variation_synonym_id"
      belongs_to :variation
      belongs_to :source
      belongs_to :subsnp_handle
    end
        
    # The VariationGroup class represents a group of variations (SNPs) that are 
    # linked and present toghether. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class VariationGroup < DBConnection
      self.primary_key = "variation_group_id"
      belongs_to :source
      has_one :variation_group_variation
      has_one :httag
      has_one :variation_group_feature
      has_one :allele_group
    end
    
    # The VariationGroupVariation class is a connection class. 
    # Should not be used directly.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class VariationGroupVariation < DBConnection
      belongs_to :variation
      belongs_to :variation_group
    end
    
    # The VariationGroupFeature class gives information on the genomic position 
    # of each VariationGroup.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class VariationGroupFeature < DBConnection
      self.primary_key = "variation_group_feature_id"
      belongs_to :variation_group
    end
    
    class VariationAnnotation < DBConnection
      self.primary_key = "variation_annotation_id"
      belongs_to :variation
      belongs_to :phenotype
      belongs_to :source
    end
    
    # The VariationSet class gives information on variations grouped by study, method, quality measure etc.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.   
    class VariationSet < DBConnection
      self.primary_key = "variation_set_id"
      has_many :variation_set_variations
      has_many :variations, :through => :variation_set_variations
    end
    
    class VariationSetVariation < DBConnection
      belongs_to :variation
      belongs_to :variation_set
    end

    # The VariationSet class gives information on super and sub VariationSets.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available. 
    class VariationSetStructure < DBConnection
      
    end
    
    
    
    # The FlankingSequence class gives information about the genomic coordinates 
    # of the flanking sequences, for a single VariationFeature. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class FlankingSequence < DBConnection
      belongs_to :variation
    end
    
    # The TaggedVariationFeature class is a connection class. 
    # Should not be used directly.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class TaggedVariationFeature < DBConnection
      belongs_to :variation_feature
      belongs_to :sample
    end
    
    class Httag < DBConnection
      self.primary_key = "httag_id"
      belongs_to :variation_group
      belongs_to :source
    end
    
  end
end