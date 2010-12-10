#!/usr/bin/ruby

require 'lib/ensembl'
include Ensembl::Core

DBConnection.ensemblgenomes_connect('bacillus_cereus_ZK',7) # Connect to the Ensembl Genomes MySQL server and fetch the data for 'bacillus_cereus_ZK'
slice = Slice.fetch_by_region('chromosome',"Chromosome",4791870,4799024) # retrieve a slice for this specie

puts "\nConnecting to 'bacillus_cereus_ZK' database..."
# show all the species inside the collection, as 'bacillus_cereus_ZK' genome is stored inside the bacillus_collection database
if  Collection.check
  puts "Is this a collection? #{Collection.check}"
  puts "\nOther species present inside the collection:"
  Collection.species.each do |s|
    puts s
  end
end

puts "\nSequence:"
# get the sequence
puts slice.seq

puts "\nGenes:"
# get all the genes overlapping the slice
genes = slice.genes
genes.each do |g|
  print "#{g.stable_id} #{g.name}\n"
end

# CHANGE DATABASE

puts "\n########################\nConnecting to 'mycobacterium_collection' database..."
DBConnection.ensemblgenomes_connect('mycobacterium_collection',7) # connect directly to a collection database
slice = Slice.fetch_by_region('chromosome',"Chromosome",752908,759374,1,"Mycobacterium tuberculosis H37Rv") # manually set the species to fetch the slice from

# show all the species inside the collection
if  Collection.check
  puts "\nIs this a collection? #{Collection.check}"
  puts "\nOther species present inside the collection:"
  Collection.species.each do |s|
    puts s
  end
end

puts "\nSequence:"
# get the sequence
puts slice.seq

puts "\nGenes:"
# get all the genes overlapping the slice
genes = slice.genes
genes.each do |g|
  print "#{g.stable_id} #{g.name}\n"
end






