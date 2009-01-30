#
# = ensembl/variation/activerecord.rb - ActiveRecord mappings to Ensembl variation
#
# Copyright::   Copyright (C) 2008 Jan Aerts <http://jandot.myopenid.com>
# License::     The Ruby License
#

nil
module Ensembl
  # = DESCRIPTION
  # The Ensembl::Variation module covers the variation databases from
  # ensembldb.ensembl.org.
  module Variation
    # = DESCRIPTION
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

    # = DESCRIPTION
    # The IndividualPopulation class is used to connect Individual and Population classes. 
    # Should not be used directly.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class IndividualPopulation < DBConnection
      belongs_to :individual
      belongs_to :population
    end
    
    # = DESCRIPTION
    # The Individual class gives information on the single individuals used 
    # to retrieve one or more biological samples.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class Individual < DBConnection
      belongs_to :sample
      # CAN'T FIGURE OUT SOME TABLE FIELDS
    end
    
    class IndividualGenotypeMultipleBp < DBConnection
      belongs_to :sample
      belongs_to :variation
    end
    
    class CompressedGenotypeSingleBp < DBConnection
      belongs_to :sample
    end  
    
    class ReadCoverage < DBConnection
      belongs_to :sample
    end
    
    class Population < DBConnection
      belongs_to :sample
    end
    
    class PopulationStructure < DBConnection
      # CAN'T FIGURE OUT SOME TABLE FIELDS
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
    end
    
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
    class Variation < DBConnection
      set_primary_key "variation_id"
      belongs_to :source
      has_one :variation_synonym
      has_one :flanking_sequence
      has_many :allele_group_alleles
      has_many :allele_groups, :through => :allele_group_alleles
      has_many :population_genotypes
      has_many :alleles
      has_one :variation_feature
      has_many :variation_group_variations
      has_many :variation_groups, :through => :variation_group_variations
      has_many :individual_genotype_multiple_bps
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
    # The VariationFeature class gives information about the genomic position of 
    # each Variation, including also validation status and consequence type. 
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.
    class VariationFeature < DBConnection
      set_primary_key "variation_feature_id"
      belongs_to :variation
      has_many :tagged_variation_features
      has_many :samples, :through => :tagged_variation_features
      has_many :transcript_variations
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
    
    # = DESCRIPTION
    # The TranscriptVariation class gives information about the position of 
    # a VariationFeature, mapped on an annotated transcript.
    #
    # This class uses ActiveRecord to access data in the Ensembl database.
    # See the general documentation of the Ensembl module for
    # more information on what this means and what methods are available.    
    class TranscriptVariation < DBConnection
      set_primary_key "transcript_variation_id"
      belongs_to :variation_feature
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