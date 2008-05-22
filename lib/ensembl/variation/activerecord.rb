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
    #
    #
    class Allele < DBConnection
      set_primary_key 'allele_id'
      
    end

    #
    #
    class AlleleGroup < DBConnection
      set_primary_key 'allele_group_id'
      
    end
  end
end