package Bio::Biblio::Provider;
use strict;
use warnings;

use parent qw(Bio::Biblio::BiblioBase);

# ABSTRACT: representation of a general provider

=head1 SYNOPSIS

    # usually this class is not instantiated but can be...
    $obj = Bio::Biblio::Provider->new(-type => 'Department');

  #--- OR ---

    $obj = Bio::Biblio::Provider->new();
    $obj->type ('Department');

=head1 DESCRIPTION

A storage object for a general bibliographic resource provider
(a rpovider can be a person, a organisation, or even a program).

=head2 Attributes

The following attributes are specific to this class,
and they are inherited by all provider types.

  type

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

1;
__END__
