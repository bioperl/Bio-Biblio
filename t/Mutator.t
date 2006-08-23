# -*-Perl-*-
# $Id$
## Bioperl Test Harness Script for Modules
##


# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

use strict;
my $error;
use vars qw($NUMTESTS);
BEGIN { 
    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    $error=0;
    use Test;
    $NUMTESTS=25;
    plan tests => $NUMTESTS;
    eval { require IO::String; };
    if( $@ ) {
	print STDERR "IO::String not installed. This means the Bio::DB::* modules are not usable. Skipping tests.\n";
	for( 1..$NUMTESTS ) {
	    skip("IO::String not installed",1);
	}
	$error = 1; 
    }
}

if( $error ==  1 ) {
    exit(0);
}

require Bio::LiveSeq::Mutator;
require Bio::LiveSeq::IO::BioPerl;
require Bio::LiveSeq::Gene;
require Bio::Root::IO;


$a = Bio::LiveSeq::Mutator->new();
ok $a;

ok $a->numbering, 'coding';
ok $a->numbering('coding 1');
ok $a->numbering, 'coding 1';

require Bio::LiveSeq::Mutation;
my $mt = new Bio::LiveSeq::Mutation;
ok $mt->seq('g');
$mt->pos(100);
ok ($a->add_Mutation($mt));
my @each = $a->each_Mutation;
ok( (scalar @each), 1 );
my $mt_b = pop @each;
ok($mt_b->seq, 'g');
my $filename=Bio::Root::IO->catfile("t","data","ar.embl");
my $loader=Bio::LiveSeq::IO::BioPerl->load('-file' => "$filename");
my $gene_name='AR'; # was G6PD

my $gene=$loader->gene2liveseq('-gene_name' => $gene_name);
ok($gene);
ok $a->gene($gene);

my $results = $a->change_gene();
ok($results);

# bug 1701 - mutations on intron/exon boundaries where codon is split 

$loader = Bio::LiveSeq::IO::BioPerl->load( -db   => 'EMBL',
                                -file => Bio::Root::IO->catfile('t','data','ssp160.embl.1')
					    );

my @positions = (3128..3130,3187..3189);
my @bases = (qw(C C C C T T));
my @expected = (qw(T683T T684P),'','',
                qw(T684I T684T));
my $ct = 0;

for my $pos (@positions) {
    # reset gene
    my $gene = $loader->gene2liveseq( -gene_name => 'ssp160');
    my $mutation = Bio::LiveSeq::Mutation->new( -seq => $bases[$ct],
                                                -pos => $pos,
                                                -verbose => -1
                          );
    $mutation->verbose(-1);
    my $mutate = Bio::LiveSeq::Mutator->new( -gene      => $gene,
                                             -numbering => 'entry',
                                             -verbose => -1
                           );
    $mutate->add_Mutation( $mutation );

    my $results = $mutate->change_gene();
    
	ok(defined($results));
	ok($expected[$ct] eq $results->trivname);
    $ct++;
}

eval { require IO::String };
if( $@ ) {
    print STDERR "IO::String not installed. Skipping output test.\n";
    skip("IO::String not installed",1);

} else {

    use Bio::Variation::IO;
    require IO::String;    
    my $s;
    my $io = IO::String->new($s);
    my $out = Bio::Variation::IO->new('-fh'   => $io,
				      '-format' => 'flat'
				      );
    ok($out->write($results));
    #print $s;
    ok ($s=~/DNA/ && $s=~/RNA/ && $s=~/AA/);
}
