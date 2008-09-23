module Ensembl
  ENSEMBL_RELEASE = 50
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
