#!/usr/bin/env perl

use utf8;
use strict;
use warnings;

use Test::More;
use Test::RequiresInternet;

use Bio::Biblio;

my $db = Bio::Biblio->new(-access => 'biofetch');
isa_ok ($db, "Bio::DB::Biblio::biofetch");

my $ref;
my @ids;

$ref = $db->get_by_id("10592273");
ok (defined ($ref));
is ($ref->identifier, "10592273");

@ids = qw(10592273 9613206);
$ref = $db->get_all(\@ids);
ok (defined ($ref));
is ($ref->next_bibref->identifier, $_) for (@ids);

@ids = qw(10592273 9613206);
$ref = $db->get_Stream_by_id(\@ids);
ok (defined ($ref));
is ($ref->next_bibref->identifier, $_) for (@ids);

done_testing();
