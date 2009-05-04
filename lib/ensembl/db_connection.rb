require 'rubygems'
require 'activerecord'

module Ensembl
  DB_ADAPTER = 'mysql'
  DB_HOST = 'ensembldb.ensembl.org'
  DB_USERNAME = 'anonymous'
  DB_PASSWORD = ''
  EG_HOST = 'mysql.ebi.ac.uk'
  EG_PORT = 4157

  class DummyDBConnection < ActiveRecord::Base
    self.abstract_class = true
  end

  module DBRegistry 
    # = DESCRIPTION
    # The Ensembl::Registry::Base is a generic super class providing general methods 
    # to get database and connection info.
    #
    class Base < ActiveRecord::Base
      self.abstract_class = true
      self.pluralize_table_names = false
      def self.get_info
        host,user,password,db_name,port = self.retrieve_connection.instance_values["connection_options"]
      end
            
      def self.get_name_from_db(match,species,release,args)
        dummy_db = DummyDBConnection.establish_connection(
                            :adapter => args[:adapter] ||= Ensembl::DB_ADAPTER,
                            :host => args[:host] ||= Ensembl::DB_HOST,
                            :username => args[:username] ||= Ensembl::DB_USERNAME,
                            :password => args[:password] ||= Ensembl::DB_PASSWORD,
                            :port => args[:port],
                            :database => ''
                          )
        dummy_connection = dummy_db.connection
        db_name = dummy_connection.select_values("SHOW DATABASES LIKE '%#{species}_#{match}_#{release.to_s}%'")[0]
        if db_name.nil? and args[:ensembl_genomes] then
          words = species.split(/_/)
          first = words.shift
          db_name = dummy_connection.select_values("SHOW DATABASES LIKE '%#{first}_collection_#{match}_#{release.to_s}%'")[0]
          others = ''
          words.each do |w|
            others << " #{w}"
          end
          Ensembl::SESSION.collection_specie = "#{first.capitalize}#{others}"
        end
        warn "WARNING: No connection to database established. Check that the species is in snake_case (was: #{species})." if db_name.nil?
        return db_name
      end
      
    end
    
  end
  
  
  module Core
    # = DESCRIPTION
    # The Ensembl::Core::DBConnection is the actual connection established
    # with the Ensembl server.
    class DBConnection < Ensembl::DBRegistry::Base
      self.abstract_class = true
      self.pluralize_table_names = false
      # = DESCRIPTION
      # The Ensembl::Core::DBConnection#connect method makes the connection
      # to the Ensembl core database for a given species. By default, it connects
      # to release 50 for that species. You _could_ use a lower number, but
      # some parts of the API might not work, or worse: give the wrong results.
      #
      # = USAGE
      #  # Connect to release 50 of human
      #  Ensembl::Core::DBConnection.connect('homo_sapiens')
      #
      #  # Connect to release 42 of chicken
      #  Ensembl::Core::DBConnection.connect('gallus_gallus')
      #
      # ---
      # *Arguments*:
      # * species:: species to connect to. Arguments should be in snake_case
      # * ensembl_release:: the release of the database to connect to
      #  (default = 50)
      def self.connect(species, release = Ensembl::ENSEMBL_RELEASE, args = {})
        Ensembl::SESSION.reset
        db_name = nil
        if args[:ensembl_genomes]
          args[:port] = EG_PORT
          args[:host] = EG_HOST
        end    
        if args[:port].nil? then
          args[:port] = ( release > 47 ) ? 5306 : 3306
        end
        if args[:database]
          db_name = args[:database]
        else 
          db_name = self.get_name_from_db('core',species,release,args)
        end 
        establish_connection(
                            :adapter => args[:adapter] || Ensembl::DB_ADAPTER,
                            :host => args[:host] || Ensembl::DB_HOST,
                            :database => db_name,
                            :username => args[:username] || Ensembl::DB_USERNAME,
                            :password => args[:password] || Ensembl::DB_PASSWORD,
                            :port => args[:port]
                          )
        
        self.retrieve_connection          
      end
      
      def self.ensemblgenomes_connect(species, release = Ensembl::ENSEMBL_RELEASE, args = {})
        args[:ensembl_genomes] = true
        self.connect(species,release,args)
      end
      
    end # Core::DBConnection

  end # Core

  module Variation
    # = DESCRIPTION
    # The Ensembl::Variation::DBConnection is the actual connection established
    # with the Ensembl server.
    class DBConnection < Ensembl::DBRegistry::Base
      self.abstract_class = true
      self.pluralize_table_names = false
      # = DESCRIPTION
      # The Ensembl::Variation::DBConnection#connect method makes the connection
      # to the Ensembl variation database for a given species. By default, it connects
      # to release 50 for that species. You _could_ use a lower number, but
      # some parts of the API might not work, or worse: give the wrong results.
      #
      # = USAGE
      #  # Connect to release 50 of human
      #  Ensembl::Variation::DBConnection.connect('homo_sapiens')
      #
      #  # Connect to release 42 of chicken
      #  Ensembl::Variation::DBConnection.connect('gallus_gallus')
      #
      # ---
      # *Arguments*:
      # * species:: species to connect to. Arguments should be in snake_case
      # * ensembl_release:: the release of the database to connect to
      #  (default = 50)
      def self.connect(species, release = Ensembl::ENSEMBL_RELEASE, args = {})
        Ensembl::SESSION.reset
        args[:species] = species
        if args[:port].nil? then
          args[:port] = ( release > 47 ) ? 5306 : 3306
        end
        db_name = nil
        if args[:database]
          db_name = args[:database]
        else
          db_name = self.get_name_from_db('variation',species,release,args)
        end
        establish_connection(
                            :adapter => args[:adapter] || Ensembl::DB_ADAPTER,
                            :host => args[:host] || Ensembl::DB_HOST,
                            :database => db_name,
                            :username => args[:username] || Ensembl::DB_USERNAME,
                            :password => args[:password] || Ensembl::DB_PASSWORD,
                            :port => args[:port]
                          )
          
        self.retrieve_connection
        
      end

    end # Variation::DBConnection
    
  end # Variation
  
end # Ensembl
