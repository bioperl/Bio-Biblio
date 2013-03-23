package Bio::Biblio::Journal;
use utf8;
use strict;
use warnings;

use parent qw(Bio::Biblio::BiblioBase);

# ABSTRACT: representation of a journal
# AUTHOR:   Martin Senger <senger@ebi.ac.uk>
# AUTHOR:   Heikki Lehvaslaiho <heikki@bioperl.org>
# OWNER:    2002 European Bioinformatics Institute
# LICENSE:  Perl_5

=head1 SYNOPSIS

    $obj = Bio::Biblio::Journal->new(-name => 'The Perl Journal',
                                     -issn  => '1087-903X');
  #--- OR ---

    $obj = Bio::Biblio::Journal->new();
    $obj->issn ('1087-903X');

=head1 DESCRIPTION

A storage object for a journal.
See its place in the class hierarchy in
http://www.ebi.ac.uk/~senger/openbqs/images/bibobjects_perl.gif

=head2 Attributes

The following attributes are specific to this class
(however, you can also set and get all attributes defined in the parent classes):

  abbreviation
  issn
  name
  provider       type: Bio::Biblio::Provider

=head1 SEE ALSO

=for :list
* OpenBQS home page
http://www.ebi.ac.uk/~senger/openbqs/
* Comments to the Perl client
http://www.ebi.ac.uk/~senger/openbqs/Client_perl.html
=back

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
         _abbreviation => undef,
         _issn => undef,
         _name => undef,
         _provider => 'Bio::Biblio::Provider',
         );

    # return 1 if $attr is allowed to be set/get in this class
    sub _accessible {
        my ($self, $attr) = @_;
        exists $_allowed{$attr};
    }

    # return an expected type of given $attr
    sub _attr_type {
        my ($self, $attr) = @_;
        $_allowed{$attr};
    }
}

1;
