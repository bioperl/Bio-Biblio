# -*-Perl-*-
## Bioperl Test Harness Script for Modules
## $Id$
#

use strict;

BEGIN {
    use vars qw($DEBUG);
    $DEBUG = $ENV{'BIOPERLDEBUG'};
    # to handle systems with no installed Test module
    # we include the t dir (where a copy of Test.pm is located)
    # as a fallback
    eval { require Test; };
    if( $@ ) {
        use lib 't';
    }
    use Test;
    plan tests => 12;
}

END {
}
require 'dumpvar.pl';

print("Checking if the Bio::Map::LinkagePosition module could be used.\n");
        # test 1
use Bio::Map::LinkagePosition;
ok(1);

print("Creating a Position with a scalar...\n");
my $position = new Bio::Map::LinkagePosition(-positions => 2,
	-distance => 22.3);
ok(1);

print("Creating a Position with a list for the position and no distance...\n");
my $position2 = new Bio::Map::LinkagePosition(-positions => qw(3 4 5));
ok(1);
	# print("position2 looks like this:\n");
	# dumpValue($position2);
	print("Checking that positions can be retrieved.\n");
my @retrieved_position = $position->each_position();
ok(pop(@retrieved_position) == 2);
	print("Checking that distance can be retrieved:\n");
ok($position->distance() == 22.3);
ok($position2->distance() == 0);
