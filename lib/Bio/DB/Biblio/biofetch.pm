package Bio::DB::Biblio::biofetch;
use utf8;
use strict;
use warnings;
use Bio::Biblio::IO;

use parent qw(Bio::DB::DBFetch Bio::Biblio);

# ABSTRACT: a BioFetch-based access to a bibliographic citation retrieval

=head1 SYNOPSIS

Do not use this object directly, only access it through the
I<Bio::Biblio> module:

  use Bio::Biblio;
  my $biblio = Bio::Biblio->new(-access => 'biofetch');
  my $ref = $biblio->get_by_id('20063307'));

  my $ids = ['20063307', '98276153'];
  my $refio = $biblio->get_all($ids);
  while ($ref = $refio->next_bibref) {
    print $ref->identifier, "\n";
  }

=head1 DESCRIPTION

This class uses BioFetch protocol based service to retrieve Medline
references by their ID.

The main documentation details are to be found in
L<Bio::DB::BiblioI>.

=head1 AUTHOR

Heikki Lehvaslaiho (heikki-at-bioperl-dot-org)

=head1 COPYRIGHT

Copyright (c) 2002 European Bioinformatics Institute. All Rights Reserved.

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 DISCLAIMER

This software is provided "as is" without warranty of any kind.

=head1 BUGS AND LIMITATIONS

=over 1

=item *

Only method get_by_id() is supported.

=back

=cut

# you can add your own here theoretically.
our %HOSTS = (
              'dbfetch' => {
                            baseurl => 'http://%s/Tools/dbfetch/dbfetch?db=medline&style=raw',
                            hosts   => {
                                        'ebi'  => 'www.ebi.ac.uk'
                                        }
                            }
              );
our %FORMATMAP = ( 'default' => 'medlinexml' );

=attr Defaults

 Usage   : print $Bio::DB::Biblio::biofetch::DEFAULT_SERVICE;

=cut

our $DEFAULT_SERVICE = 'http://www.ebi.ac.uk/Tools/dbfetch/dbfetch';
our $DEFAULTRETRIEVAL_TYPE = 'tempfile';


sub new {
    my ($class, @args ) = @_;
    my $self = $class->SUPER::new(@args);

    $self->{ '_hosts' } = {};
    $self->{ '_formatmap' } = {};

    $self->hosts(\%HOSTS);
    $self->formatmap(\%FORMATMAP);
        $self->retrieval_type($DEFAULTRETRIEVAL_TYPE);
    $self->{'_default_format'} = $FORMATMAP{'default'};

    return $self;
}

=method get_by_id

 Title   : get_by_id
 Usage   : $entry = $db->get__by_id('20063307')
 Function: Gets a Bio::Biblio::RefI object by its name
 Returns : a Bio::Biblio::Medline object
 Args    : the id (as a string) of the reference

=cut

sub get_by_id {
    my ($self,$id) = @_;
    my $io = $self->get_Stream_by_id([$id]);
    $self->throw("id does not exist") if( !defined $io ) ;
    return $io->next_bibref();
}


=method get_all

  Title   : get_all
  Usage   : $seq = $db->get_all($ref);
  Function: Retrieves reference objects from the server 'en masse',
            rather than one  at a time.  For large numbers of sequences,
            this is far superior than get_by_id().
  Example :
  Returns : a stream of Bio::Biblio::Medline objects
  Args    : $ref : either an array reference, a filename, or a filehandle
            from which to get the list of unique ids/accession numbers.

=cut

sub get_all {
    my ($self, $ids) = @_;
    return $self->get_seq_stream('-uids' => $ids, '-mode' => 'single');
}

=method get_seq_stream

 Title   : get_seq_stream
 Usage   : my $seqio = $self->get_seq_stream(%qualifiers)
 Function: builds a url and queries a web db
 Returns : a Bio::SeqIO stream capable of producing sequence
 Args    : %qualifiers = a hash qualifiers that the implementing class
           will process to make a url suitable for web querying

=cut

sub get_seq_stream {
        my ($self, %qualifiers) = @_;
        my ($rformat, $ioformat) = $self->request_format();
        my $seen = 0;
        foreach my $key ( keys %qualifiers ) {
                if( $key =~ /format/i ) {
                        $rformat = $qualifiers{$key};
                        $seen = 1;
                }
        }
        $qualifiers{'-format'} = $rformat if( !$seen);
        ($rformat, $ioformat) = $self->request_format($rformat);

        my $request = $self->get_request(%qualifiers);
        my ($stream,$resp);
        if ( $self->retrieval_type =~ /temp/i ) {
                my $dir = $self->io()->tempdir( CLEANUP => 1);
                my ( $fh, $tmpfile) = $self->io()->tempfile( DIR => $dir );
                close $fh;
                my ($resp) = $self->_request($request, $tmpfile);
                if( ! -e $tmpfile || -z $tmpfile || ! $resp->is_success() ) {
                        $self->throw("WebDBSeqI Error - check query sequences!\n");
                }
                $self->postprocess_data('type' => 'file',
                                        'location' => $tmpfile);
                # this may get reset when requesting batch mode
                ($rformat,$ioformat) = $self->request_format();
                if ( $self->verbose > 0 ) {
                        open(my $ERR, "<", $tmpfile);
                        while(<$ERR>) { $self->debug($_);}
                }
                $stream = Bio::Biblio::IO->new('-format' => $ioformat,
                                               '-file'   => $tmpfile);
        } elsif ( $self->retrieval_type =~ /io_string/i ) {
                my ($resp) = $self->_request($request);
                my $content = $resp->content_ref;
                $self->debug( "content is $$content\n");
                if( ! $resp->is_success() || length(${$resp->content_ref()}) == 0 ) {
                        $self->throw("WebDBSeqI Error - check query sequences!\n");
                }
                ($rformat,$ioformat) = $self->request_format();
                $self->postprocess_data('type'=> 'string',
                                        'location' => $content);
                $stream = Bio::Biblio::IO->new('-format' => $ioformat,
#                                               '-data'   => "<tag>". $$content. "</tag>");
                                               '-data'   => $$content
                                                );
        } else {
                $self->throw("retrieval type " . $self->retrieval_type . " unsupported\n");
        }
        return $stream;
}


=method postprocess_data

 Title   : postprocess_data
 Usage   : $self->postprocess_data ( 'type' => 'string',
                                     'location' => \$datastr);
 Function: process downloaded data before loading into a Bio::SeqIO
 Returns : void
 Args    : hash with two keys - 'type' can be 'string' or 'file'
                              - 'location' either file location or string
                                           reference containing data

=cut

# the default method, works for genbank/genpept, other classes should
# override it with their own method.

sub postprocess_data {
        my ($self, %args) = @_;
        my ($data, $TMP);
        my $type = uc $args{'type'};
        my $location = $args{'location'};
        if( !defined $type || $type eq '' || !defined $location) {
                return;
        } elsif( $type eq 'STRING' ) {
                $data = $$location;
        } elsif ( $type eq 'FILE' ) {
                open($TMP, "<", $location) or $self->throw("could not open file $location");
                my @in = <$TMP>;
                $data = join("", @in);
        }

        if( $type eq 'FILE'  ) {
                open($TMP, ">", $location) or $self->throw("could overwrite file $location");
                print $TMP $data;
        } elsif ( $type eq 'STRING' ) {
                ${$args{'location'}} = $data;
        }

        $self->debug("format is ". $self->request_format(). " data is $data\n");
}

1;
