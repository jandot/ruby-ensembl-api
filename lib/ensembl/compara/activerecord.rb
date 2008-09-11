module Ensembl
  # = DESCRIPTION
  # The Ensembl::Compara module covers the compara database from
  # ensembldb.ensembl.org and includes genome alignments and orthology information.
  # For a full description of the database (and therefore the classes that
  # are available), see http://www.ensembl.org/info/software/core/schema/index.html
  # and http://www.ensembl.org/info/software/core/schema/schema_description.html
  #
  # = USAGE
  # To connect to the compara database, simply add 'ComparaDBConnection.connect'
  # to the beginning of your script. Also do not forget to 'include Compara'.
  require 'bio'
  include Ensembl::Core
    
  module Compara
   
    class NcbiTaxaNode < ComparaDBConnection
      
    end
    
    class NcbiTaxaName < ComparaDBConnection
      has_one :genome_db
      
    end
    
    # = DESCRIPTION
    # Dnafrag (ments) are strecthes of DNA that have been used
    # for alignments in pariwise or multiple species genomic
    # alignments. Sub-sections are referred to by the genomic_align
    # table in which information on aligned sequences are stored.
    #
    # = USAGE
    # dna = Dnafrag.find_by_dnafrag_id(1)
    # slice = dna.get_slice
    class Dnafrag < ComparaDBConnection
      
      belongs_to :genome_db, :foreign_key => "genome_db_id"
      has_many :genomic_aligns
      
      set_primary_key 'dnafrag_id'
      
      def coord_system_name
        self.slice.seq_region.coord_system.name
      end
      
      def display_id
        return dnafrag_id.to_s
      end
      
      def genome_db
        return GenomeDb.find_by_genome_db_id(genome_db_id)
      end
      
      def slice
        
        seq_name = self.name
        start = 0
        stop = self.length
        strand = "1" ## FixMe!
        
        self.genome_db.connect_to_genome
        seq_region = SeqRegion.find_by_name(self.name)
        return Slice.new(seq_region, start, stop, strand)
        
      end
      
      def self.fetch_by_slice(genome_db,slice)
        
        fragment = nil
        coord = slice.seq_region.coord_system.name
        location = slice.seq_region.name
        fragment = Dnafrag.find(:first, :conditions => ["name = ? and coord_system_name = ? and genome_db_id = ?", location,coord,genome_db.genome_db_id,])
        return fragment
        
      end
      
      def get_aligned_section(linked_id,snorna)
        result = nil
        result = GenomicAlign.find(:first, :conditions => ["dnafrag_id = ? and method_link_species_set_id = ? and dnafrag_start < ? and dnafrag_end > ?", self.dnafrag_id, linked_id, snorna.slice.start, snorna.slice.stop])
        return result
      end
      
    end
    
    # = DESCRIPTION
    # Dna fragments are associated with the respective
    # genome database. A connection is required to fetch
    # any type of sequence data (slices) from the core database.
    # For dnafrag objects this is done automatically when using
    # the #get_slice method.
    #
    # = USAGE
    # gdb = GenomeDb.find_by_name('homo_sapiens')
    # gdb.connect_to_genome
    # slice = Slice.fetch_by_gene_stable_id('...')
    class GenomeDb < ComparaDBConnection

      has_many  :dnafrags
      has_many :species_sets
      has_many :method_link_species_sets, :through => :species_sets
      belongs_to :ncbi_taxa_name 
      
      set_primary_key 'genome_db_id'
      
      def get_all_db_links
        
        answer = Array.new
        sets = SpeciesSet.find_all_by_genome_db_id(self.genome_db_id)
        sets.each do |set|
          answer.push(MethodLinkSpeciesSet.find(:all, :conditions => ["species_set_id = ?", set.species_set_id]))
        end
        
        return answer.sort.uniq!
        
      end
      
      def connect_to_genome
        species = self.name.gsub(/\s/, '_').downcase
        DBConnection.connect(species)
      end  
      
      def find_all_sets
        return SpeciesSet.find(:all, :conditions => ["genome_db_id = ?", self.genome_db_id])
      end
      
      def find_all_pairwise(method_link_id)
        answer = Array.new
        sets = self.find_all_sets
        sets.each do |set|
          answer.push(MethodLinkSpeciesSet.find(:all, :conditions => ["species_set_id = ? and method_link_id = ?", set.species_set_id,method_link_id]))
        end
        return answer.flatten
      end  
      
      def find_pairwise_set_id(method_link_id,species_2)
        
        answer = nil
        method_species_sets = self.find_all_pairwise(1)
        method_species_sets.each do |set|
          set = SpeciesSet.find_all_by_species_set_id(set.species_set_id)
          set.each do |s|
            if s.genome_db_id == species_2.genome_db_id
              answer = MethodLinkSpeciesSet.find_by_species_set_id(s.species_set_id)
            end
          end
        end
          
        return answer
        
      end
        
      def linked_genomes_by_method_link_id(method_link_id)
        answer = Array.new
        pairs = self.find_all_pairwise(method_link_id)
        pairs.each do |pair|
          set_id = pair.species_set_id
          set = SpeciesSet.find_all_by_species_set_id(set_id)
          set.each do |s|
            unless s.genome_db_id == self.genome_db_id
              answer.push(GenomeDb.find(s.genome_db_id))
            end
          end
        end
        return answer
      end

    end
    
    # = DESCRIPTION
    # Genomic Align Blocks are used to group aligned
    # sequences of a given set of species and method.
    class GenomicAlignBlock < ComparaDBConnection
      
      set_primary_key 'genomic_align_block_id'
      has_many :dnafrags, :foreign_key => "dnafrag_id"
      has_many :genomic_aligns, :foreign_key => "genomic_align_block_id", :order => "genomic_align_id"
      
      def alignment_strings
        
        answer = Array.new
        alignments = GenomicAlign.find_all_by_genomic_align_block_id(self.genomic_align_block_id)
        alignments.each do |al|
          answer.push(al.gapped_sequence)
        end
        
        return answer
   
      end
      
      def get_sequences
        
        answer = Array.new
        
        pieces = GenomicAlign.find_all_by_genomic_align_block_id(self.genomic_align_block_id)
        
        pieces.each do |piece|
          
          frag = Dnafrag.find_by_dnafrag_id(piece.dnafrag_id)
          sequence = frag.slice(piece.dnafrag_start,piece.dnafrag_end,piece.dnafrag_strand)
          answer.push(sequence.seq)
          
        end
        
        return answer
        
      end
      
    end
    
    # = DESCRIPTION
    # Genomic Align objects refer to each sequence (dnafrag) 
    # in a genomic alignment, grouped by a 
    # genomic_align_block_id (referring to the species
    # and alignment method).
    class GenomicAlign < ComparaDBConnection
      
      belongs_to :genomic_align_block
      belongs_to :dnafrag , :foreign_key => "dnafrag_id"
      
      set_primary_key 'genomic_align_id'
      
      def display_id
        organism_name = self.dnafrag.genome_db.taxon_id
        genomedb = self.dnafrag.genome_db.genome_db_id
        coord = self.dnafrag.slice.seq_region.coord_system.name
        dna_name = self.dnafrag.name
        start = self.dnafrag_start
        stop = self.dnafrag_end
        
        return "#{organism_name}:#{genomedb}:#{coord}:#{dna_name}:#{start}:#{stop}:#{self.dnafrag_strand}"
        
      end  
                    
      def aligned_sequence # returns the dna fragment in its aligned state using the cigar line information
        
        cigar_line = "#{self.cigar_line}"
        ungapped_sequence = "#{self.get_slice.seq}"
        
        new_sequence = ""
        
        while cigar_line.length > 0
          
          if cigar_line.match(/^[0-9]/)
            elements = cigar_line.slice!(/[0-9]*[A-Z]/)
            x = elements.gsub(/[A-Z]/, '').to_i # Decoding of the cigar line compression scheme
            symbol = elements.gsub(/[0-9]*/, '')
          else
            x = 1 # No compression
            symbol = cigar_line.slice!(0..0)
          end
          
          if symbol == "D" # Deletions/Gaps
            x.times do
              new_sequence = new_sequence + "-"
            end
          elsif symbol == "M" # Match/Mismatch
            x.times do
              new_sequence = new_sequence + ungapped_sequence.slice!(0..0)
            end
          end
        
        end
        return "#{new_sequence}"
        
      end 
              
      def find_organism
        fragment = Dnafrag.find_by_dnafrag_id(self.dnafrag_id)
        genome_db = GenomeDb.find_by_genome_db_id(fragment.genome_db_id)
        return genome_db.name
      end
      
      def get_slice
        
          start, stop, strand = nil, nil, nil
          
          start = self.dnafrag_start
          stop = self.dnafrag_end
          strand = self.dnafrag_strand
        
          self.dnafrag.genome_db.connect_to_genome
        
          return Ensembl::Core::Slice.new(SeqRegion.find_by_name(self.dnafrag.name), start, stop, strand)        
        
      end
    
      def relative_position(gene) #maps the position of a gene onto the alignment (start position only)
        
        gene_strand = "#{gene.slice.strand}"
        fragment_strand = "#{self.dnafrag_strand}"
        
        if  "#{gene_strand}" == "-1" and "#{fragment_strand}" == "-1"
          gene_start = self.dnafrag_end-gene.slice.stop
        elsif "#{gene_strand}" == "1" and "#{fragment_strand}" == "1"
          gene_start = gene.slice.start-self.dnafrag_start
        elsif "#{gene_strand}" == "1" and "#{fragment_strand}" == "-1"
          gene_start = self.dnafrag_end-gene.slice.stop
        else
          gene_start = gene.slice.start-self.dnafrag_start
        end
        
        cigar_line = "#{self.cigar_line}"
        counter = -1 # DNA starts at 1, not 0 - hence string count needs to be shifted by 1 to find cases where gene_start = 0 (=1)
        gapped_counter = 0
        
        while counter < gene_start
          
          if cigar_line.match(/^[0-9]/)
            elements = cigar_line.slice!(/^[0-9]*[A-Z]/)
            x = elements.gsub(/[A-Z]/, '').to_i
            symbol = elements.gsub(/[0-9]*/, '')
          else
            x = 1
            symbol = cigar_line.slice!(0..0)
          end
          
          if symbol == "D" or symbol == "X"
            gapped_counter += x
          else
            x.times do
              if counter < gene_start
                gapped_counter += 1
                counter += 1
              end
            end
          end
        
        end
        
        return gapped_counter-1
        
      end
      
      
  
    end
    
    # = DESCRIPTION
    # Species sets group species using a common
    # identifier - used in the method_link_species_set
    # class (joining organisms and alingment method information). 
    class SpeciesSet < ComparaDBConnection
      
      belongs_to :genome_dbs, :foreign_key => 'genome_db_id'
      belongs_to :method_link_species_sets
      
      def find_set(method_link_id,genome_dbs)
        
        
          
      end
      
        
    end
    
    class MethodLink < ComparaDBConnection
      
      has_many :method_link_species_sets
      
      set_primary_key 'method_link_id'  
      
    end
    
    class MethodLinkSpeciesSet < ComparaDBConnection

      belongs_to :method_link, :foreign_key => "method_link_id"
      has_many :species_sets, :foreign_key => "species_set_id"
      has_many :genomic_align
      
      def fetch_blocks
        return GenomicAlignBlock.find_all_by_method_link_species_set_id(self.method_link_species_set_id)
      end
      
      def get_alignments
        return GenomicAlign.find_all_by_method_link_species_id(self.method_link_species_id)
      end
      
    end
    
  end
  
  
end