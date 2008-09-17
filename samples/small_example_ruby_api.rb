#!/usr/bin/ruby
require '../lib/ensembl'

include Ensembl::Core

DBConnection.connect('homo_sapiens')

puts "== Get a slice =="
slice = Slice.fetch_by_region('chromosome','4',10000,99999,-1)
puts slice.display_name

puts "== Print all gene for that slice (regardless of what coord_system genes are annotated on) =="
slice.genes.each do |gene|
  puts gene.stable_id + "\t" + gene.status + "\t" + gene.slice.display_name
end

puts "== Get a transcript and print its 5'UTR, CDS and protein sequence =="
transcript = Transcript.find_by_stable_id('ENST00000380593')
puts "5'UTR: " + transcript.five_prime_utr_seq
puts "CDS: " + transcript.cds_seq
puts "peptide: " + transcript.protein_seq

DBConnection.connection.disconnect!
DBConnection.connect('bos_taurus',45)

puts "== Transforming a cow gene from chromosome level to scaffold level =="
gene = Gene.find(2408)
cloned_gene = gene.transform('scaffold')
puts "Original: " + gene.slice.display_name
puts "Now: " + cloned_gene.slice.display_name

puts "== What things are related to a 'gene' object? =="
puts 'Genes belong to: ' + Gene.reflect_on_all_associations(:belongs_to).collect{|a| a.name.to_s}.join(',')
puts 'Genes have many: ' + Gene.reflect_on_all_associations(:has_many).collect{|a| a.name.to_s}.join(',')