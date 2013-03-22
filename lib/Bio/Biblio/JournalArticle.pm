package Bio::Biblio::JournalArticle;
use strict;
use warnings;

use parent qw(Bio::Biblio::Article);

# ABSTRACT: representation of a journal article

=head1 SYNOPSIS

    $obj = Bio::Biblio::JournalArticle->new(-title => 'Come to grief',
                                            -journal => Bio::Biblio::Journal->new());
  #--- OR ---

    $obj = Bio::Biblio::JournalArticle->new();
    $obj->title ('Come to grief');
    $obj->journal (Bio::Biblio::Journal->new(-name => 'English Mysteries'));

=head1 DESCRIPTION

A storage object for a journal article.
See its place in the class hierarchy in
http://www.ebi.ac.uk/~senger/openbqs/images/bibobjects_perl.gif

=head2 Attributes

The following attributes are specific to this class
(however, you can also set and get all attributes defined in the parent classes):

  issue
  issue_supplement
  journal           type: Bio::Biblio::Journal
  volume

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
         _issue => undef,
         _issue_supplement => undef,
         _journal => 'Bio::Biblio::Journal',
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
__END__
