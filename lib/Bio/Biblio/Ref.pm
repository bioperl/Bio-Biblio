package Bio::Biblio::Ref;

use utf8;
use strict;
use warnings;
use Bio::Annotation::DBLink;

use parent qw(Bio::Biblio::BiblioBase);

# ABSTRACT: representation of a bibliographic reference
# AUTHOR:   Martin Senger <senger@ebi.ac.uk>
# AUTHOR:   Heikki Lehvaslaiho <heikki@bioperl.org>
# OWNER:    2002 European Bioinformatics Institute
# LICENSE:  Perl_5

=head1 SYNOPSIS

    $obj = Bio::Biblio::Ref->new(-type  => 'Letter',
                                 -title => 'Onegin to Tatiana');
  #--- OR ---

    $obj = Bio::Biblio::Ref->new();
    $obj->type ('Letter');

=head1 DESCRIPTION

A storage object for a general bibliographic reference (a citation).
See its place in the class hierarchy in
http://www.ebi.ac.uk/~senger/openbqs/images/bibobjects_perl.gif

=head2 Attributes

The following attributes are specific to this class,
and they are inherited by all citation types.

  author_list_complete            values: 'Y'  (default) or 'N'
  authors                         type:   array ref of Bio::Biblio::Provider's
  cross_references                type:   array ref of Bio::Annotation::DBLink's
  cross_references_list_complete  values: 'Y' (default) or 'N'
  abstract
  abstract_language
  abstract_type
  codes                           type:   hash ref
  contributors                    type:   array ref of Bio::Biblio::Provider's
  date
  date_completed
  date_created
  date_revised
  format
  identifier
  keywords
  language
  last_modified_date
  publisher                       type:   Bio::Biblio::Provider
  repository_subset
  rights
  spatial_location
  subject_headings                type:   hash ref
  subject_headings_source
  temporal_period
  title
  toc
  toc_type
  type

=head1 SEE ALSO

=for :list
* OpenBQS home page
http://www.ebi.ac.uk/~senger/openbqs/
* Comments to the Perl client
http://www.ebi.ac.uk/~senger/openbqs/Client_perl.html
=cut

our $AUTOLOAD;

#
# a closure with a list of allowed attribute names (these names
# correspond with the allowed 'get' and 'set' methods); each name also
# keep what type the attribute should be (use 'undef' if it is a
# simple scalar)
#
{
    my %_allowed =
        (
         _author_list_complete => undef,
         _authors => 'ARRAY',  # of Bio::Biblio::Provider
         _cross_references => 'ARRAY',   # of Bio::Annotation::DBLink
         _cross_references_list_complete => undef,
         _abstract => undef,
         _abstract_language => undef,
         _abstract_type => undef,
         _codes => 'HASH',
         _contributors => 'ARRAY',  # of Bio::Biblio::Provider
         _date => undef,
         _date_completed => undef,
         _date_created => undef,
         _date_revised => undef,
         _format => undef,
         _identifier => undef,
         _keywords => 'HASH',
         _language => undef,
         _last_modified_date => undef,
         _publisher => 'Bio::Biblio::Provider',
         _repository_subset => undef,
         _rights => undef,
         _spatial_location => undef,
         _subject_headings => 'HASH',
         _subject_headings_source => undef,
         _temporal_period => undef,
         _title => undef,
         _toc => undef,
         _toc_type => undef,
         _type => undef,
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


=method add_cross_reference

 Usage   : $self->add_cross_reference
               (Bio::Annotation::DBLink->new(-database   => 'EMBL',
                                             -primary_id => 'V00808');
 Function: adding a link to a database entry
 Returns : new value of 'cross_references'
 Args    : an object of type Bio::Annotation::DBLink

=cut

sub add_cross_reference {
    my ($self, $value) = @_;
    $self->throw ($self->_wrong_type_msg (ref $value, 'Bio::Annotation::DBLink'))
        unless (UNIVERSAL::isa ($value, 'Bio::Annotation::DBLink'));
    (defined $self->cross_references) ?
        push (@{ $self->cross_references }, $value) :
            return $self->cross_references ( [$value] );
    return $self->cross_references;
}


=method add_author

 Usage   : $self->add_author (Bio::Biblio::Person->new(-lastname => 'Novak');
 Function: adding an author to a list of authors
 Returns : new value of 'authors' (a full list)
 Args    : an object of type Bio::Biblio::Provider

=cut


sub add_author {
    my ($self, $value) = @_;
    $self->throw ($self->_wrong_type_msg (ref $value, 'Bio::Biblio::Provider'))
        unless (UNIVERSAL::isa ($value, 'Bio::Biblio::Provider'));
    (defined $self->authors) ?
        push (@{ $self->authors }, $value) :
            return $self->authors ( [$value] );
    return $self->authors;
}

=method add_contributor

 Usage   : $self->add_contributor (Bio::Biblio::Person->new(-lastname => 'Novak');
 Function: adding a contributor to a list of contributors
 Returns : new value of 'contributors' (a full list)
 Args    : an object of type Bio::Biblio::Provider

=cut

sub add_contributor {
    my ($self, $value) = @_;
    $self->throw ($self->_wrong_type_msg (ref $value, 'Bio::Biblio::Provider'))
        unless (UNIVERSAL::isa ($value, 'Bio::Biblio::Provider'));
    (defined $self->contributors) ?
        push (@{ $self->contributors }, $value) :
            return $self->contributors ( [$value] );
    return $self->contributors;
}

1;
