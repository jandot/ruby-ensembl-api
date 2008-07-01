#
# = ensembl/variation/activerecord.rb - ActiveRecord mappings to Ensembl variation
#
# Copyright::   Copyright (C) 2008 Jan Aerts <jan.aerts@sanger.ac.uk>
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
      
    end
  end
end