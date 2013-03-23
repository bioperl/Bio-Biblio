package Bio::Biblio::Article;
use utf8;
use strict;
use warnings;

use parent qw(Bio::Biblio::Ref);

# ABSTRACT: representation of a general article

=head1 SYNOPSIS

    $obj = Bio::Biblio::Article->new(-identifier => '123abc',
                                     -first_page => 23,
                                     -last_page  => 68);
  #--- OR ---

    $obj = Bio::Biblio::Article->new();
    $obj->identifier ('123abc');
    $obj->first_page (23);
    $obj->last_page (68);

=head1 DESCRIPTION

A storage object for a general article.
See its place in the class hierarchy in
http://www.ebi.ac.uk/~senger/openbqs/images/bibobjects_perl.gif

=head2 Attributes

The following attributes are specific to this class
(however, you can also set and get all attributes defined in the parent classes):

  first_page
  last_page


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
         _first_page => undef,
         _last_page => undef,
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
