#
# = ensembl/core/project.rb - project calculations for Ensembl Slice
#
# Copyright::   Copyright (C) 2009 Francesco Strozzi <francesco.strozzi@gmail.com>
#                           
# License::     The Ruby License

module Ensembl
  nil
  module Core
    # = DESCRIPTION
    # Class to describe and handle multi-species databases
    #
    class Collection
      # = DESCRIPTION
      # Method to check if the current core database is a multi-species db.
      # Returns a boolean value.
      #
      def self.check()
        host,user,password,db_name,port = Ensembl::Core::DBConnection.get_info
        if db_name =~/(\w+)_collection_core_.*/ 
          return true
        end
        return false
      end

      # = DESCRIPTION
      # Returns an array with all the Species present in a collection database.
      #  
      def self.species()
        return Meta.find_all_by_meta_key("species.db_name").collect {|m| m.meta_value}
      end
      
      # = DESCRIPTION
      # Returns the species_id of a particular specie present in the database.
      #      
      def self.get_species_id(specie)
        meta = Meta.find_by_meta_value(specie)
        if meta.nil?
          return nil
        else
          return meta.species_id
        end
      end
      
      # = DESCRIPTION
      # Returns an array with all the coord_system_id associated with a particular specie and a table_name.
      # Used inside Slice#method_missing to filter the coord_system_id using a particular species_id.
      #
      def self.find_all_coord_by_table_name(table_name,species_id)
        all_ids = CoordSystem.find_all_by_species_id(species_id)
        return MetaCoord.find_all_by_coord_system_id_and_table_name(all_ids,table_name)
      end
      
    end
    
    
  end
end