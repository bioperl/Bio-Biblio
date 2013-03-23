package Bio::Biblio::Person;
use utf8;
use strict;
use warnings;

use parent qw(Bio::Biblio::Provider);

# ABSTRACT: representation of a person
# AUTHOR:   Martin Senger <senger@ebi.ac.uk>
# AUTHOR:   Heikki Lehvaslaiho <heikki@bioperl.org>
# OWNER:    2002 European Bioinformatics Institute
# LICENSE:  Perl_5

=head1 SYNOPSIS

    $obj = Bio::Biblio::Person->new(-lastname => 'Capek',
                                    -firstname => 'Karel');
  #--- OR ---

    $obj = Bio::Biblio::Person->new();
    $obj->firstname ('Karel');
    $obj->lastname ('Capek');

=head1 DESCRIPTION

A storage object for a person related to a bibliographic resource.

=head2 Attributes

The following attributes are specific to this class
(however, you can also set and get all attributes defined in the parent classes):

  affiliation
  email
  firstname
  forename
  initials
  lastname
  middlename
  postal_address
  suffix

=head1 SEE ALSO

=for :list
* OpenBQS home page
http://www.ebi.ac.uk/~senger/openbqs/
* Comments to the Perl client
http://www.ebi.ac.uk/~senger/openbqs/Client_perl.html
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
         _affiliation => undef,
         _email => undef,
         _firstname => undef,
         _forename => undef,
         _initials => undef,
         _lastname => undef,
         _middlename => undef,
         _postal_address => undef,
         _suffix => undef,
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
