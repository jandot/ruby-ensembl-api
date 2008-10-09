#!/usr/bin/ruby

# Based on Perl API tutorial 
# http://www.ensembl.org/info/using/api/variation/variation_tutorial.html


require File.dirname(__FILE__) + '/../lib/ensembl.rb'
include Ensembl::Core
include Ensembl::Variation

Ensembl::Variation::DBConnection.connect('homo_sapiens',50)
# The connection with the Core database can be omitted. It is created automatically
# when needed, using Variation DB connection parameters. The database name is derived 
# from Variation DB name. If you are using non conventional DB names (i.e. local connection)
# an exception will be raised. Otherwise, if a Core DB connection is already 
# present, that connection will be used by default, instead of creating a new one.

id = ['rs1367827','rs1367830']

id.each do |i|
  v = Variation.find_by_name(i)
  v.variation_features.each do |vf|
    
    up_seq,down_seq = vf.flanking_seq # retrieve upstream and downstream flanking sequences
    
    seq_region_name = vf.fetch_region.seq_region.name # fetch the genomic region of the Variation and get the region name.
                                                      # Automatically sets the connection with Core DB, if necessary.
    
    puts "== VARIATION FEATURE =="
    print "#{vf.variation_name} #{vf.allele_string} #{vf.consequence_type} #{up_seq.seq} #{down_seq.seq} #{seq_region_name}\n"
    vf.transcript_variations.each do |tv|
      t = tv.transcript # retrieve Ensembl::Core::Transcript from Core DB. Automatically sets the connection, if necessary. 
      puts "== TRANSCRIPT VARIATION =="
      print "#{tv.peptide_allele_string} #{t.stable_id} #{t.gene.stable_id}\n"
    end
  end
end

# Returns all Variations present on a gemomic region

puts "== SEARCHING FOR VARIATIONS ON CHR:1:50000:51000 =="

# Even in this case, Variation DB connection can be set automatically by specific Slice methods

s = Slice.fetch_by_region('chromosome',1,50000,51000) 
variation_features = s.get_variation_features # automatically sets the connection with Variation DB, if necessary.
variation_features.each do |vf|
  print "#{vf.variation_name} #{vf.allele_string} #{vf.consequence_type} #{vf.fetch_region.seq_region.name}\n"
end

puts "== GENOTYPED VARIATIONS =="

genotyped_variation_features = s.get_genotyped_variation_features # automatically sets the connection with Variation DB, if necessary.
genotyped_variation_features.each do |gvf|
  print "#{gvf.variation_name} #{gvf.allele_string} #{gvf.consequence_type} #{gvf.fetch_region.seq_region.name}\n"
end
