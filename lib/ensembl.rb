module Ensembl
  ENSEMBL_RELEASE = 52

  class Session
    attr_accessor :coord_systems
    attr_accessor :seqlevel_id, :seqlevel_coord_system
    attr_accessor :toplevel_id, :toplevel_coord_system
    attr_accessor :coord_system_ids #map CS id to CS name
    attr_accessor :seq_regions

    def initialize
      @coord_systems = Hash.new # key = id; value = CoordSystem object
      @coord_system_ids = Hash.new # key = id; value = name
      @seq_regions = Hash.new
    end
  end

  SESSION = Ensembl::Session.new

end

begin
  require 'rubygems'
  require 'bio'
  rescue LoadError
    raise LoadError, "You must have bioruby installed"
end

# Database connection
require File.dirname(__FILE__) + '/ensembl/db_connection.rb'

# Core modules
require File.dirname(__FILE__) + '/ensembl/core/activerecord.rb'
require File.dirname(__FILE__) + '/ensembl/core/transcript.rb'
require File.dirname(__FILE__) + '/ensembl/core/slice.rb'
require File.dirname(__FILE__) + '/ensembl/core/project.rb'
require File.dirname(__FILE__) + '/ensembl/core/transform.rb'

# Variation modules
require File.dirname(__FILE__) + '/ensembl/variation/activerecord.rb'

