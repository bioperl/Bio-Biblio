package Bio::Biblio::MedlineJournal;
use strict;
use warnings;

use parent qw(Bio::Biblio::Journal);

# ABSTRACT: representation of a MEDLINE journal

=head1 SYNOPSIS

    $obj = Bio::Biblio::MedlineJournal->new
               (-medline_ta => 'J Vasc Interv Radiol');
  #--- OR ---

    $obj = Bio::Biblio::MedlineJournal->new();
    $obj->medline_ta ('J Vasc Interv Radiol');

=head1 DESCRIPTION

A storage object for a MEDLINE journal.
See its place in the class hierarchy in
http://www.ebi.ac.uk/~senger/openbqs/images/bibobjects_perl.gif

=head2 Attributes

The following attributes are specific to this class
(however, you can also set and get all attributes defined in the parent classes):

  coden
  country
  medline_code
  medline_ta
  nlm_unique_id

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

#
# a closure with a list of allowed attribute names (these names
# correspond with the allowed 'get' and 'set' methods); each name also
# keep what type the attribute should be (use 'undef' if it is a
# simple scalar)
#
{
    my %_allowed =
        (
         _coden => undef,
         _country => undef,
         _medline_code => undef,
         _medline_ta => undef,
         _nlm_unique_id => undef,
         );

    # return 1 if $attr is allowed to be set/get in this class
    sub _accessible {
        my ($self, $attr) = @_;
        exists $_allowed{$attr} or $self->SUPER::_accessible ($attr);
    }

    # return an expected type of given $attr
    sub _attr_type {
        my ($self, $attr) = @_;
        if (exists $_allowed{$attr}) {
            return $_allowed{$attr};
        } else {
            return $self->SUPER::_attr_type ($attr);
        }
    }
}

1;
