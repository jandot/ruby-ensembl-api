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
    # = USAGE
    #  allele = Allele.find(1)
    #  puts allele.to_yaml
    class Allele < DBConnection
      set_primary_key 'allele_id'
      belongs_to :sample
      belongs_to :variation
      belongs_to :population
      belongs_to :subsnp_handle
    end

    # = DESCRIPTION
    # The AlleleGroup class represents a grouping of alleles that have tight 
    # linkage and are usually present together. This is commonly known as a 
    # Haplotype or Haplotype Block. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    #
    # = USAGE
    #  allele_group = AlleleGroup.find(1)
    #  puts allele_group.to_yaml
    class AlleleGroup < DBConnection
      set_primary_key 'allele_group_id'
      belongs_to :variation_group
      belongs_to :source
      belongs_to :sample
      belongs_to :allele_group_allele
    end
    
    # = DESCRIPTION
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
    
    # = DESCRIPTION
    # Store information on attributes types
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class AttribType < DBConnection
      set_primary_key "attrib_type_id"
    end 
    
    
    # = DESCRIPTION
    # 
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class ConsequenceMapping < DBConnection
      
    end

    # = DESCRIPTION
    # 
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class FailedDescription < DBConnection
      set_primary_key "failed_description_id"
      has_many :failed_variations
    end
    
    # = DESCRIPTION
    # 
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class FailedVariation < DBConnection
      set_primary_key "failed_variation_id"
      belongs_to :failed_description
      belongs_to :variation
    end    
    
    # = DESCRIPTION
    # 
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class FeatureType < DBConnection
      set_primary_key "feature_type_id"
    end
        
    class Meta < DBConnection
      set_primary_key "meta_id"
    end
    
    class MetaCoord < DBConnection
     
    end
    
    class Phenotype < DBConnection
      set_primary_key "phenotype_id"
      has_many :variation_annotations
    end
    
    
    
    # = DESCRIPTION
    # The Sample class gives information about the biological samples stored in the database. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class Sample < DBConnection
      set_primary_key "sample_id"
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
    
    # = DESCRIPTION
    # The Individual class gives information on the single individuals used 
    # to retrieve one or more biological samples.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class Individual < DBConnection
      set_primary_key "sample_id"
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
      set_primary_key "invidual_type_id"
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
      set_primary_key "sample_id"
      has_many :population_genotypes, :foreign_key => "sample_id"
      has_many :individual_populations, :foreign_key => "population_sample_id"
      has_many :individuals, :through => :individual_populations
      has_many :sample_synonyms
      has_one :population_structure
      has_many :tagged_variation_features
      has_many :alleles
      has_many :allele_groups
    end
    
    class PopulationStructure < DBConnection
      
    end
    
    # = DESCRIPTION
    # The PopulationGenotype class gives information about alleles and allele 
    # frequencies for a SNP observed within a population or a group of samples. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class PopulationGenotype < DBConnection
      set_primary_key "population_genotype_id"
      belongs_to :variation
      belongs_to :population
      belongs_to :subsnp_handle
      has_many :compressed_genotype_single_bps, :foreign_key => "sample_id"
    end
    
    # = DESCRIPTION
    # The SampleSynonym class represents information about alternative names 
    # for sample entries. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class SampleSynonym < DBConnection
      set_primary_key "sample_synonym_id"
      belongs_to :source
      belongs_to :sample
      belongs_to :population
    end
    
    # = DESCRIPTION
    # The Source class gives information on the different databases and SNP 
    # panels used to retrieve the data
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class Source < DBConnection
      set_primary_key "source_id"
      has_many :sample_synonyms
      has_many :allele_groups
      has_many :variations
      has_many :variation_groups
      has_many :httags
      has_many :variation_synonyms
      has_many :variation_annotations
      has_many :structural_variations
    end
    
    class StructuralVariation < DBConnection
      set_primary_key "structural_variation_id"
      belongs_to :source
      belongs_to :seq_region
      
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
      set_primary_key "seq_region_id"
      has_many :variation_features
      has_many :structural_variations
    end
    
    class SubsnpHandle < DBConnection
      set_primary_key "subsnp_id"
      has_many :individual_genotype_multiple_bps, :foreign_key => "subsnp_id"
      has_many :population_genotypes, :foreign_key => "subsnp_id"
      has_many :alleles, :foreign_key => "subsnp_id"
      has_many :variation_synonyms,:foreign_key => "subsnp_id"
    end
    
    # = DESCRIPTION
    # The VariationSynonym class gives information on alterative names used 
    # for Variation entries. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class VariationSynonym < DBConnection
      set_primary_key "variation_synonym_id"
      belongs_to :variation
      belongs_to :source
      belongs_to :subsnp_handle
    end
        
    # = DESCRIPTION
    # The VariationGroup class represents a group of variations (SNPs) that are 
    # linked and present toghether. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class VariationGroup < DBConnection
      set_primary_key "variation_group_id"
      belongs_to :source
      has_one :variation_group_variation
      has_one :httag
      has_one :variation_group_feature
      has_one :allele_group
    end
    
    # = DESCRIPTION
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
    
    # = DESCRIPTION
    # The VariationGroupFeature class gives information on the genomic position 
    # of each VariationGroup.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class VariationGroupFeature < DBConnection
      set_primary_key "variation_group_feature_id"
      belongs_to :variation_group
    end
    
    class VariationAnnotation < DBConnection
      set_primary_key "variation_annotation_id"
      belongs_to :variation
      belongs_to :phenotype
      belongs_to :source
    end
    
    
    # = DESCRIPTION
    # The FlankingSequence class gives information about the genomic coordinates 
    # of the flanking sequences, for a single VariationFeature. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class FlankingSequence < DBConnection
      belongs_to :variation
    end
    
    # = DESCRIPTION
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
      set_primary_key "httag_id"
      belongs_to :variation_group
      belongs_to :source
    end
    
  end
end