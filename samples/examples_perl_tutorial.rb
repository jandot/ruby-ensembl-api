#!/usr/local/bin/ruby

require File.dirname(__FILE__) + '/../lib/ensembl.rb'
require 'yaml'
require 'progressbar'

include Ensembl::Core

## Connecting to the Database
DBConnection.connect('homo_sapiens')

## Object adaptors
# not necessary, ruby uses class methods instead

## Slices
puts "== Some slices: =="
puts Slice.fetch_by_region('chromosome','X').to_yaml
puts Slice.fetch_by_region('clone','AL359765.6').to_yaml
puts Slice.fetch_by_region('supercontig','NT_011333').to_yaml
puts Slice.fetch_by_region('chromosome', '20', 1000000, 2000000).to_yaml
puts Slice.fetch_by_gene_stable_id('ENSG00000099889', 5000).to_yaml

puts "== All chromosomes: =="
Slice.fetch_all('chromosome', 'NCBI36').each do |chr|
  puts chr.display_name
end

puts "== Number of clone slices: " + Slice.fetch_all('clone').length.to_s

puts "== Subslices of chromosome 19 (length = 10000000; overlap = 250): =="
Slice.fetch_by_region('chromosome','19').split(10000000, 250).each do |sub_slice|
  puts sub_slice.display_name
end

puts "== Sequence of a very small slice: Chr19:112200..112250 =="
slice = Slice.fetch_by_region('chromosome','19',112200,112250)
puts slice.seq

puts "== Query a slice about itself =="
puts slice.to_yaml

puts "== Get genes for a slice =="
slice = Slice.fetch_by_region('chromosome','19',112200,1122000)
slice.genes.each do |gene|
  puts gene.stable_id
end

puts "== Get DNA alignment features for 20:80000..88000 =="
slice = Slice.fetch_by_region('chromosome','20',80000,88000)
slice.dna_align_features[0..2].each do |daf|
  puts daf.to_yaml
end

puts "== Get sequence for transcript ENST00000383673 =="
transcript = Transcript.find_by_stable_id('ENST00000383673')
puts transcript.seq

puts "== Get synonyms for marker D9S1038E =="
marker = Ensembl::Core::Marker.find_by_name('D9S1038E')
marker.marker_synonyms[0..5].each do |ms|
  puts ms.to_yaml
end

puts "== Get 5 features for this marker =="
marker = Ensembl::Core::Marker.find_by_name('D9S1038E')
marker.marker_features[0..5].each do |mf|
  puts 'name: ' + marker.name
  puts 'seq_region name: ' + mf.seq_region.name
  puts 'start: ' + mf.seq_region_start.to_s
  puts 'stop: ' + mf.seq_region_end.to_s
end

puts "== Get 5 features for chromosome 22 =="
slice = Ensembl::Core::Slice.fetch_by_region('chromosome', '22')
slice.marker_features.slice(0,5).each do |mf|
  puts mf.marker.name + "\t" + mf.slice.display_name
end

puts "== Transcript: from cDNA to genomic positions =="
transcript = Ensembl::Core::Transcript.find(276333)
puts "Transcript is ENST00000215574"
puts "Genomic position 488053 is cDNA position: " + transcript.genomic2cdna(488053).to_s
puts "cDNA position 601 is genomic position: " + transcript.cdna2genomic(601).to_s
puts "Genomic position 488053 is CDS position: " + transcript.genomic2cds(488053).to_s
puts "CDS position 401 is genomic position: " + transcript.cds2genomic(401).to_s

puts "== Transcript: get pieces of DNA for a transcript =="
transcript = Ensembl::Core::Transcript.find_by_stable_id('ENST00000380593')
puts transcript.stable_id
puts "5'UTR: " + transcript.five_prime_utr_seq
puts "3'UTR: " + transcript.three_prime_utr_seq
puts "CDS: " + transcript.cds_seq
puts "protein: " + transcript.protein_seq

#### And now we'll do some stuff with cows.
CoreDBConnection.connection.disconnect!
CoreDBConnection.connect('bos_taurus')

puts "== Projecting a slice from component to assembly: =="
puts "==   scaffold Chr4.003.105:42..2007 to chromosome level =="
source_slice = Slice.fetch_by_region('scaffold','Chr4.003.105', 42, 2007)
target_slices = source_slice.project('chromosome')
puts target_slices.collect{|s| s.display_name}.join("\n")

puts "== Projecting a slice from assembly to components: =="
puts "==   chromosome slice chr4:329500..380000 to contig level =="
source_slice = Slice.fetch_by_region('chromosome', '4', 329500, 380000)
target_slices = source_slice.project('contig')
puts target_slices.collect{|s| s.display_name}.join("\n")

puts "== Transforming a gene from chromosome level to scaffold level =="
gene = Gene.find(2408)
cloned_gene = gene.transform('scaffold')
puts gene.slice.display_name
puts cloned_gene.slice.display_name

puts "== Relationships for Gene class =="
puts 'belongs to: ' + Gene.reflect_on_all_associations(:belongs_to).collect{|a| a.name.to_s}.join(',')
puts 'has many: ' + Gene.reflect_on_all_associations(:has_many).collect{|a| a.name.to_s}.join(',')

