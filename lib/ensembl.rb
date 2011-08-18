#
# = ensembl.rb
#
# Copyright::   Copyright (C) 2009 Jan Aerts <http://jandot.myopenid.com>
#               Francesco Strozzi <francesco.strozzi@gmail.com>
#                           
# License::     The Ruby License
#
# @author Jan Aerts
# @author Francesco Strozzi

module Ensembl
  ENSEMBL_RELEASE = 60
  
  class Session
    attr_accessor :coord_systems
    attr_accessor :seqlevel_id, :seqlevel_coord_system
    attr_accessor :toplevel_id, :toplevel_coord_system
    attr_accessor :coord_system_ids #map CS id to CS name
    attr_accessor :seq_regions
    attr_accessor :collection_species
    attr_accessor :release

    def initialize
      @coord_systems = Hash.new # key = id; value = CoordSystem object
      @coord_system_ids = Hash.new # key = id; value = name
      @seq_regions = Hash.new
      @release = ENSEMBL_RELEASE
    end
    
    def reset
      @coord_systems = Hash.new
      @coord_system_ids = Hash.new
      @seq_regions = Hash.new
      @seqlevel_id = nil
      @toplevel_id = nil
      @seqlevel_coord_system = nil
      @toplevel_coord_system = nil
      @collection_species = nil
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
require File.dirname(__FILE__) + '/ensembl/core/collection.rb'

# Variation modules
require File.dirname(__FILE__) + '/ensembl/variation/activerecord.rb'

class ActiveRecord::Base
  def self.belongs_to_what
    return self.reflect_on_all_associations(:belongs_to).collect{|a| a.name.to_s}
  end
  
  def self.has_what
    a = [self.reflect_on_all_associations(:has_one), self.reflect_on_all_associations(:has_many)]
    return a.flatten.uniq.collect{|a| a.name.to_s}
  end
end
