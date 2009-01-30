#
# = test/unit/test_seq.rb - Unit test for Ensembl::Core
#
# Copyright::   Copyright (C) 2007
#               Jan Aerts <http://jandot.myopenid.com>
# License::     Ruby's
#
# $Id:
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'yaml'
require 'ensembl'

include Ensembl::Core

DBConnection.connect('homo_sapiens')

class SequenceForSlice < Test::Unit::TestCase
  def test_forward_strand_seqlevel
    slice = Slice.new(SeqRegion.find(170931),5,15)
    seq = 'gcagtggtgtg'
    assert_equal(seq, slice.seq)
  end

  def test_reverse_strand_seqlevel
    slice = Slice.new(SeqRegion.find(170931),5,15, -1)
    seq = 'cacaccactgc'
    assert_equal(seq, slice.seq)
  end

  def test_forward_strand_not_seqlevel_single_target
    slice = Slice.new(SeqRegion.find(226044),69437100,69437110)
    seq = 'gtctatttaca'
    assert_equal(seq, slice.seq)
  end

  def test_reverse_strand_not_seqlevel_single_target
    slice = Slice.new(SeqRegion.find(226044),69437100,69437110,-1)
    seq = 'tgtaaatagac'
    assert_equal(seq, slice.seq)
  end

  def test_forward_strand_not_seqlevel_composite_target
    seq = ''
    File.open('../../data/seq_forward_composite.fa').reject{|l| l=~/^>/}.each do |line|
      line.chomp!
      seq += line
    end
    seq.downcase!
    slice = Slice.new(SeqRegion.find(226044),69387650,69487649)
    assert_equal(seq, slice.seq)
  end

  def test_reverse_strand_not_seqlevel_composite_target
    slice = Slice.new(SeqRegion.find(226044),69437061,69437160,-1)
    assert_equal('nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnatgtaaatagacaactaacaagatagctgagattgtttccttatccagaca', slice.seq)
  end

end

class SequenceForUnsplicedFeature < Test::Unit::TestCase
  def test_forward_strand_seqlevel
    marker_feature = MarkerFeature.find(1323757)
    marker_seq = 'ggcttacttggaaaggtctcttccaacccaatattattcaaatactttcaattttcttctaatgtttttagtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtgtggttttgttttatttcttttaattctctgatacatttagaatttcttttattattttattttattttattatttatttatttatttttgagacagagttttgctc'
    assert_equal(marker_seq, marker_feature.seq)
  end

  def test_reverse_strand_seqlevel
    gene = Gene.find_by_name('ANKRD56')

    ankrd56_seq = 'atggcccgagagctgagccaggaggcactactggactttctgtgccaggctgggggccgcgtgaccaacgctgccttgctgagccacttcaagagctttctccgagaccccgacgcgtcccccagccagcaccagcaccgccgcgagctcttcaagggcttcgtcaactcggtcgccgcagtgcgccaggaccccgacggcaccaagtacgtggtgctcaagaggagatacagggaccttttgggggaggaggggctgcagcgaccccgcgagccgcccgcggccgcccccagtgcagggggagctgcgccctgctccccgcgaggcgcgcgccggggggagccgccccagcagcagcccaggcggcggcggcgcgagaaggagccggaggaggagccagcaggtgcagcagccagagccgccgacgcagcttgcaatggactcccgggcagcgactcccgtagggcgcccgggaagggcggcggatcgaagggcagtcccggacagaggccgccggtgcccgcagctgcagcggcaggggcccaggcgagagcgagctgcgcggcggcgaagacgcagggccgctgctgctgggaatgcctccagaacaacctggctgtactgccgggagagctcggcgcactcccgcactcggccaccgcggaggagaagccggcacgggctctgcctgcccaggatgaccgcggggcttccagggagcgggaagaaggcgcgctagctgagccggcgcctgtgcctgcagtggctcactcgcctcccgccaccgtcgaggctgcgacaagcagggcttccccgcctgctctcctgcccggccccgctccccgcggagaccggccggagctgctgacccccagctccctgcattattcgaccctgcagcagcagcagcagcgcactcgagagtgggtggccaggcacccgcaggtgcccgaggcccgtgatcagggccctatccgcgcctggtcggtgctgccagacaacttcctccagctgcccttggaacccggctccacggagcctaattcagagccgccagacccctgtctttcctcgcactctctctttcctgttgttccggatgagtcctgggaatcctgggcggggaacccttcattgactgtctttcgcagcattcgttgtcagctgtccctccaagatctggatgactttgtggaccaggagagtgatggcagtgaggagagcagcagtgggcccaaagactccccgggggcttctgaagaggggctgcaggttgtcttgggaaccccagatagggggaagctcaggaatccagctgggggcctttctgtatctcggaaggagggcagccccagccggagccctcagggtctcagaaacagaggggatggtcacatctctcagcaggtccctgcaggggctaatggccttgcaggccaccccctgaagcctttgccttggccagttcctaagttaaggaggtccctcaggaggagctctctggcagggagagccaaattgtcctcctctgatgaggagtacctcgatgagggcttgctgaaaagaagtcggcgcccacctcgatccaggaagccctccaaggcaggaacggcacccagcccaagggttgatgcaggtttatcactaaaacttgcagaggttaaggctgttgtggccgagcggggttggcgacacagcctgtgggtccccagtggggaggggtctgcagccttggccccccacagaacttctgagcacaaatcatccctggttccactagatgccagggagcatgagtggattgtgaagcttgccagtggctcctggattcaggtgtggactttgttctgggaggaccctcaactggccttgcacaaagactttttgactgggtacactgcgttgcactggatagccaaacatggtgacctcagggcccttcaggacttggtgtctggagcaaagaaggcagggattgtccttgatgtaaacgtgaggtccagttgtggatataccccgctgcaccttgcagccattcacggccaccagggggtcatcaaattgctagtgcaaaggttggcttctcgggtaaatgtcagggacagcagtgggaagaagccatggcagtatctaaccagtaatacctctggggaaatatggcagctgttgggagctcctcggggcaagcccattttccctgtctatcccttagttggaagttcttcccctaccagaaaggccaagagcaaggaaatatctagaagtgtcacccgaaaaacttccttcgctgcactactcaaaagtcagcacaacaagtggaaactggccaaccagtatgagaaattccacagtccaagggaaagagaagagtatagtgactga'
    assert_equal(ankrd56_seq, gene.seq)
  end

  def test_reverse_strand_not_seqlevel
    gene = Gene.find_by_name('DRD3')
    drd3_gene_seq = ''
    File.open('../../data/seq_drd3_gene.fa').reject{|l| l=~/^>/}.each do |line|
      line.chomp!
      drd3_gene_seq += line
    end
    drd3_gene_seq.downcase!
    assert_equal(drd3_gene_seq, gene.seq)

  end

  def test_exon
    exon = Exon.find(719588)
    assert_equal('atggcatctctgagccagctgagtggccacctgaactacacctgtggggcagagaactccacaggtgccagccaggcccgcccacatgcctactatgccctctcctactgcgcgctcatcctggccatcgtcttcggcaatggcctggtgtgcatggctgtgctgaaggagcgggccctgcagactaccaccaactacttagtagtgagcctggctgtggcagacttgctggtggccaccttggtgatgccctgggtggtatacctggag', exon.seq)
  end

end

class SequenceForSlicedFeature < Test::Unit::TestCase
  def test_transcript_foward
    transcript = Transcript.find(276333)
    ub2r1_transcript_seq = ''
    File.open('../../data/seq_ub2r1_transcript.fa').reject{|l| l=~/^>/}.each do |line|
      line.chomp!
      ub2r1_transcript_seq += line
    end
    ub2r1_transcript_seq.downcase!
    assert_equal(ub2r1_transcript_seq, transcript.seq)

  end

  def test_transcript_reverse
    transcript = Transcript.find(276225)
    cso19_transcript_seq = ''
    File.open('../../data/seq_cso19_transcript.fa').reject{|l| l=~/^>/}.each do |line|
      line.chomp!
      cso19_transcript_seq += line
    end
    cso19_transcript_seq.downcase!
    assert_equal(cso19_transcript_seq, transcript.seq)
  end

end

class SequenceForCDS < Test::Unit::TestCase
  def setup
    # Transcript tr_fw is ENST00000215574
    @tr_fw = Transcript.find(276333)
    # Transcript tr_rev is ENST00000315489
    @tr_rev = Transcript.find(276225)
  end

  def test_cds_fw
    ub2r1_coding_seq = ''
    File.open('../../data/seq_ub2r1_coding.fa').reject{|l| l=~/^>/}.each do |line|
      line.chomp!
      ub2r1_coding_seq += line
    end
    ub2r1_coding_seq.downcase!
    assert_equal(ub2r1_coding_seq, @tr_fw.cds_seq)
  end

  def test_cds_rev
    cso19_coding_seq = ''
    File.open('../../data/seq_cso19_coding.fa').reject{|l| l=~/^>/}.each do |line|
      line.chomp!
      cso19_coding_seq += line
    end
    cso19_coding_seq.downcase!
    assert_equal(cso19_coding_seq, @tr_rev.cds_seq)
  end

  def test_five_prime_utr_fw
    assert_equal('GGCAAGCGCCGGTGGGGCGGCGGCGCCAGAGCTGCTGGAGCGCTCGGGGTCCCCGGGCGGCGGCGGCGGCGCAGAGGAGGAGGCAGGCGGCGGCCCCGGTGGCTCCCCCCCGGACGGTGCGCGGCCCGGCCCGTCTCGCGAACTCGCGGTGGTCGCGCGGCCCCGCGCTGCTCCGACCCCGGGCCCCTCCGCCGCCGCC'.downcase, @tr_fw.five_prime_utr_seq)
  end

  def test_five_primer_utr_rev
    assert_equal('ACTCGATCCCGGCCCCACTTCCAGGCCAGTGTCCGGCCGACCAGCCTGCCTTGGGCCAGGGCCCCACGACTCCCTGCTGCGGGACAAGAGGCCGTCTGTGCGGCTGTGGTCGTGGGAGGGTGTGGTGAGGCCGTGAAGGTGGGGACGGTGCCTGGGCCTGTGGCCGCCAGAGCTGCTGCGGCTCAGAAGGTAGCACCAGGCCCCGTGGGTGCTGTGGGGGCCATCGCCTGCCCACC'.downcase, @tr_rev.five_prime_utr_seq)
  end

  def test_three_prime_utr_fw
    assert_equal('CACCACCAGAATAAACTTGCCGAGTTTACCTCACTAGGGCCGGACCCGTGGCTCCTTAGACGACAGACTACCTCACGGAGGTTTTGTGCTGGTCCCCGTCTCCTCTGGTTGTTTCGTTTTGGCTTTTTCTCCCTCCCCATGTCTGTTCTGGGTTTTCACGTGCTTCAGAGAAGAGGGGCTGCCCCACCGCCACTCACGTCACTCGGGGCTCGGTGGACGGGCCCAGGGTGGGAGCGGCCGGCCCACCTGTCCCCTCGGGAGGGGAGCTGAGCCCGACTTCTACCGGGGTCCCCCAGCTTCCGGACTGGCCGCACCCCGGAGGAGCCACGGGGGCGCTGCTGGGAACGTGGGCGGGGGGCCGTTTCCTGACACTACCAGCCTGGGAGGCCCAGGTGTAGCGGTCCGAGGGGCCCGGTCCTGCCTGTCAGCTCCAGGTCCTGGAGCCACGTCCAGCACAGAGTGGACGGATTCACCGTGGCCGACTCTTTTCCCTGCTTTGGTTTGTTTGAAATCTAAATAAAACTACTTTATG'.downcase, @tr_fw.three_prime_utr_seq)
  end

  def test_three_prime_utr_rev
    assert_equal('GCCAGGCCTGTTTCCCACACAGTGAACGGGGGGCTGGCGGGCCTCTCCTGGGGCCTGGCTTTGGCTGGAGGGGCTAGAAGGCGAGAGGGGCTGGGAAAGGAGTCTTCCCTCCCCTTTCCTGAACTGTCCAGGTCCTTCTAGGACACCTGATCCTTCCAGTCCCTGGGGGCTGTGACCCATGGCCCTGTGCAGGGTGCAGGGTGAGTCTCCTTCCAGTGCCCCAGTTTCTTCCAGGTCACGCCAGGCCAGGCCAGGCCAGGTGGGGAAAGGGACACCTTCCGGCCCTCCCCAGTAGCTGGCTGGAGATGGAGCTTCCTGTGTCCCAGAACTCGGCGTCCAGCTCCACTAGGGCCTGGATCCCCATCACAGCTTGGGTTAGCCCCGGTCCCAGCCCAAACTCAGGCTGGAGGCAGCCCCGAGGCCTGTGCCTTTCCCACTCCACCTTCTACAGTTGCTTAGCCAATAAACCTTTCCTGGGCTGGAG'.downcase, @tr_rev.three_prime_utr_seq)
  end

  def test_protein_fw
    assert_equal('MARPLVPSSQKALLLELKGLQEEPVEGFRVTLVDEGDLYNWEVAIFGPPNTYYEGGYFKARLKFPIDYPYSPPAFRFLTKMWHPNIYETGDVCISILHPPVDDPQSGELPSERWNPTQNVRTILLSVISLLNEPNTFSPANVDASVMYRKWKESKGKDREYTDIIRKQVLGTKVDAERDGVKVPTTLAEYCVKTKAPAPDEGSDLFYDDYYEDGEVEEEADSCFGDDEDDSGTEES*', @tr_fw.protein_seq)
  end

  def test_protein_rev
    assert_equal('MGTLSCDSTPRLATAPLGRRVTEGQIPETGLRKSCGTATLENGSGPGLYVLPSTVGFINHDCTRVASPAYSLVRRPSEAPPQDTSPGPIYFLDPKVTRFGRSCTPAYSMQGRAKSRGPEVTPGPGAYSPEKVPPVRHRTPPAFTLGCRLPLKPLDTSAPAPNAYTMPPLWGSQIFTKPSSPSYTVVGRTPPARPPQDPAEIPGPGQYDSPDANTYRQRLPAFTMLGRPRAPRPLEETPGPGAHCPEQVTVNKARAPAFSMGIRHSKRASTMAATTPSRPAGHRLPGRCC*', @tr_rev.protein_seq)
  end
end

