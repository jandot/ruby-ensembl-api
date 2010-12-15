#
# = ensembl/db_connection.rb - Connection classes for Ensembl databases
#
# Copyright::   Copyright (C) 2009 Jan Aerts <http://jandot.myopenid.com>
#               Francesco Strozzi <francesco.strozzi@gmail.com>
#                           
# License::     The Ruby License
#


require 'rubygems'
require 'active_record'

module Ensembl
  DB_ADAPTER = 'mysql'
  DB_HOST = 'ensembldb.ensembl.org'
  DB_USERNAME = 'anonymous'
  DB_PASSWORD = ''
  EG_HOST = 'mysql.ebi.ac.uk'
  EG_PORT = 4157


  # Generic class to perform dynamic connections to the Ensembl database and retrieve database names
  class DummyDBConnection < ActiveRecord::Base
    self.abstract_class = true
    def self.connect(args)
      self.establish_connection(
                :adapter => args[:adapter] ||= Ensembl::DB_ADAPTER,
                :host => args[:host] ||= Ensembl::DB_HOST,
                :username => args[:username] ||= Ensembl::DB_USERNAME,
                :password => args[:password] ||= Ensembl::DB_PASSWORD,
                :port => args[:port],
                :database => args[:database] ||= ''
               )
    end           
  end

  module DBRegistry 
    # The Ensembl::Registry::Base is a super class providing general methods 
    # to get database and connection info.
    class Base < ActiveRecord::Base
      self.abstract_class = true
      self.pluralize_table_names = false
      def self.get_info
        host,user,password,db_name,port = self.retrieve_connection.instance_values["connection_options"]
        db_name =~/(\w+_\w+)_(core|variation|funcgen|compara)_(\d+)_\S+/
        species,release = $1,$3 # just works for standard Ensembl database names
        if species.nil? and release.nil? then
          raise NameError, "Can't get database name from #{db_name}. Are you using non conventional names?"
        else
          return host,user,password,db_name,port,species,release.to_i
        end
      end
      
      # Method to retrieve the name of a database, using species, release and connection parameters
      # passed by the user.    
      def self.get_name_from_db(db_type,species,release,args)
        species = species.underscore # Always in lowercase. This keeps things simple when dealing with complex species names like in Ensembl Genomes database
        dummy_db = DummyDBConnection.connect(args)
        dummy_connection = dummy_db.connection
        # check if a database exists with exactly the species name passed (regular way)
        db_name = dummy_connection.select_values("SHOW DATABASES LIKE '%#{species}_#{db_type}_#{release.to_s}%'")[0]
        # if a database is not found and we are working on Ensembl Genomes database...
        if db_name.nil? and args[:ensembl_genomes] then
          words = species.split(/_/)
          first = words.shift
          # ...try to find a collection database using the first name of the species passed (convention used for collection databases)
          db_name = dummy_connection.select_values("SHOW DATABASES").select {|d| d=~/#{first}.*_collection_#{db_type}_#{release.to_s}/}[0]
          # if a collection database match is found, then look inside to find the species
          if db_name != nil then
            dummy_db.disconnect! # close the generic connection with the host
            args[:database] = db_name
            dummy_db = DummyDBConnection.connect(args) # open a new connection directly with the collection database
            species_name = species.gsub(first,first[0..0]) # transform the species name, so it can match the species names stored in the collection database
            Ensembl::SESSION.collection_species = species_name # set the species used for this session, so it's easier to fetch slices from the genome of that species
            
            # check that the species passed is present in the collection database, otherwise returns a warning
            exists = dummy_db.connection.select_values("SELECT species_id FROM meta WHERE LOWER(meta_value) = '#{species_name}' AND meta_key = 'species.db_name'")[0]
            warn "WARNING: No species '#{species}' found in the database. Please check that the name is correct." if !exists
          end
        end
        warn "WARNING: No connection to database established. Check that the species is in snake_case (was: #{species})." if db_name.nil?
        return db_name
      end
      
      def self.generic_connect(db_type, species, release, args = {})
        Ensembl::SESSION.reset
        db_name = nil
        # if the connection is established with Ensembl Genomes, set the default port and host
        if args[:ensembl_genomes] then
          args[:port] = EG_PORT
          args[:host] = EG_HOST
        end    
        if args[:port].nil? then
          args[:port] = ( release > 47 ) ? 5306 : 3306
        end
        if args[:database]
          db_name = args[:database]
        else 
          db_name = self.get_name_from_db(db_type,species,release,args) # try to find the corresponding database 
        end 
        establish_connection(
                            :adapter => args[:adapter] || Ensembl::DB_ADAPTER,
                            :host => args[:host] || Ensembl::DB_HOST,
                            :database => db_name,
                            :username => args[:username] || Ensembl::DB_USERNAME,
                            :password => args[:password] || Ensembl::DB_PASSWORD,
                            :port => args[:port]
                          )
        
        self.retrieve_connection # Check if the connection is working       
      end      
      
    end
    
  end
  
  
  module Core
    # The Ensembl::Core::DBConnection is the actual connection established
    # with the Ensembl server.
    class DBConnection < Ensembl::DBRegistry::Base
      self.abstract_class = true
      self.pluralize_table_names = false
      # The Ensembl::Core::DBConnection#connect method makes the connection
      # to the Ensembl core database for a given species. By default, it connects
      # to release 50 for that species. You _could_ use a lower number, but
      # some parts of the API might not work, or worse: give the wrong results.
      #
      # @example
      #  # Connect to release 50 of human
      #  Ensembl::Core::DBConnection.connect('homo_sapiens')
      #
      #  # Connect to release 42 of chicken
      #  Ensembl::Core::DBConnection.connect('gallus_gallus')
      #
      # @param [String] species Species to connect to. Must be in snake_case
      # @param [Integer] ensembl_release. Release to connect to (default = 60)
      def self.connect(species, release = Ensembl::ENSEMBL_RELEASE, args = {})
        self.generic_connect('core',species, release,args)
      end
      
      def self.ensemblgenomes_connect(species, release = Ensembl::ENSEMBL_RELEASE, args={})
        args[:ensembl_genomes] = true
        self.generic_connect('core',species,release,args)
      end

      
    end # Core::DBConnection

  end # Core

  module Variation
    # The Ensembl::Variation::DBConnection is the actual connection established
    # with the Ensembl server.
    class DBConnection < Ensembl::DBRegistry::Base
      self.abstract_class = true
      self.pluralize_table_names = false
      # The Ensembl::Variation::DBConnection#connect method makes the connection
      # to the Ensembl variation database for a given species. By default, it connects
      # to release 50 for that species. You _could_ use a lower number, but
      # some parts of the API might not work, or worse: give the wrong results.
      #
      # @example
      #  # Connect to release 50 of human
      #  Ensembl::Variation::DBConnection.connect('homo_sapiens')
      #
      #  # Connect to release 42 of chicken
      #  Ensembl::Variation::DBConnection.connect('gallus_gallus')
      #
      # @param [String] species Species to connect to. Must be in snake_case
      # @param [Integer] ensembl_release. Release to connect to (default = 60)
      def self.connect(species, release = Ensembl::ENSEMBL_RELEASE, args = {})
        self.generic_connect('variation',species, release, args)
      end
      
      def self.ensemblgenomes_connect(species, release = Ensembl::ENSEMBL_RELEASE, args={})
        args[:ensembl_genomes] = true
        self.generic_connect('variation',species,release,args)
      end      

    end # Variation::DBConnection
    
  end # Variation
  
end # Ensembl
