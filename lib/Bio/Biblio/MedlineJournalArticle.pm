package Bio::Biblio::MedlineJournalArticle;
use utf8;
use strict;
use warnings;

use parent qw(Bio::Biblio::MedlineArticle Bio::Biblio::JournalArticle);

# ABSTRACT: representation of a MEDLINE journal article

=head1 SYNOPSIS

    $obj = Bio::Biblio::MedlineJournalArticle->new(
                  -title => 'Thermal adaptation analyzed by comparison of protein sequences from mesophilic and extremely thermophilic Methanococcus species.',
                  -journal => Bio::Biblio::MedlineJournal->new(-issn => '0027-8424'),
                  -volume => 96,
                  -issue => 7);
  #--- OR ---

    $obj = Bio::Biblio::MedlineJournalArticle->new();
    $obj->title ('...');
    $obj->journal (Bio::Biblio::MedlineJournal->new(-issn => '0027-8424'));

=head1 DESCRIPTION

A storage object for a MEDLINE journal article.
See its place in the class hierarchy in
http://www.ebi.ac.uk/~senger/openbqs/images/bibobjects_perl.gif

=head2 Attributes

The following attributes are specific to this class
(however, you can also set and get all attributes defined in the parent classes):

  journal           type: Bio::Biblio::MedlineJournal

=head1 SEE ALSO

=over 4

=item *

OpenBQS home page: http://www.ebi.ac.uk/~senger/openbqs/

=item *

Comments to the Perl client: http://www.ebi.ac.uk/~senger/openbqs/Client_perl.html

=back

=head1 AUTHORS

Heikki Lehvaslaiho (heikki-at-bioperl-dot-org),
Martin Senger (senger@ebi.ac.uk)

=head1 COPYRIGHT

Copyright (c) 2002 European Bioinformatics Institute. All Rights Reserved.

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 DISCLAIMER

This software is provided "as is" without warranty of any kind.

=cut

our @ISA;
#
# a closure with a list of allowed attribute names (these names
# correspond with the allowed 'get' and 'set' methods); each name also
# keep what type the attribute should be (use 'undef' if it is a
# simple scalar)
#
{
    my %_allowed =
        (
         _journal => 'Bio::Biblio::MedlineJournal',
         );

    # return 1 if $attr is allowed to be set/get in this class
    sub _accessible {
        my ($self, $attr) = @_;
        return 1 if exists $_allowed{$attr};
        foreach my $parent (@ISA) {
            return 1 if $parent->_accessible ($attr);
        }
    }

    # return an expected type of given $attr
    sub _attr_type {
        my ($self, $attr) = @_;
        if (exists $_allowed{$attr}) {
            return $_allowed{$attr};
        } else {
            foreach my $parent (@ISA) {
                if ($parent->_accessible ($attr)) {
                    return $parent->_attr_type ($attr);
                }
            }
        }
        return 'unknown';
    }
}

1;
