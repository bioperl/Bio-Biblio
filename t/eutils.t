#!/usr/bin/env perl

use utf8;
use strict;
use warnings;

use Test::More;

use Bio::Biblio;
use Bio::Biblio::IO;

my $db = Bio::Biblio->new(-access => "eutils");
ok (defined ($db) && ref ($db) eq "Bio::DB::Biblio::eutils");

## these aren't exactly the most stringent of tests
my $search = '"Day A"[AU] AND ("Database Management Systems"[MH] OR "Databases,'.
             ' Genetic"[MH] OR "Software"[MH] OR "Software Design"[MH])';
$db->find($search);
my $ct = 0;
$ct++ while (my $xml = $db->get_next);
cmp_ok ($ct, ">=", 4);

my $biblio = Bio::Biblio->new( -access => 'eutils' );
ok (defined $biblio);

ok (! $biblio->count);
$biblio->find("12368254");
is ($biblio->count, 1);

my $io = Bio::Biblio::IO->new( -data => $biblio->get_next,
                               -format => 'medlinexml' );
my $article = $io->next_bibref();
is ($article->identifier, "12368254");

done_testing();
