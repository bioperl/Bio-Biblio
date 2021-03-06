package Bio::Biblio::Book;

use utf8;
use strict;
use warnings;

use parent qw(Bio::Biblio::Ref);

# ABSTRACT: Representation of a book
# AUTHOR:   Martin Senger <senger@ebi.ac.uk>
# AUTHOR:   Heikki Lehvaslaiho <heikki@bioperl.org>
# OWNER:    2002 European Bioinformatics Institute
# LICENSE:  Perl_5

=head1 SYNOPSIS

    $obj = Bio::Biblio::Book->new(-identifier => '123abc',
                                  -editor => Bio::Biblio::Person->new
                                            (-lastname => 'Loukides'),
                                  -isbn  => '0-596-00068-5');
  #--- OR ---

    $obj = Bio::Biblio::Book->new();
    $obj->isbn ('0-596-00068-5');

=head1 DESCRIPTION

A storage object for a book.
See its place in the class hierarchy in
http://www.ebi.ac.uk/~senger/openbqs/images/bibobjects_perl.gif

=head2 Attributes

The following attributes are specific to this class
(however, you can also set and get all attributes defined in the parent classes):

  edition
  editor    type: Bio::Biblio::Provider
  isbn
  series
  title
  volume

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
         _edition => undef,
         _editor => 'Bio::Biblio::Provider',
         _isbn => undef,
         _series => undef,
         _title => undef,
         _volume => undef,
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
