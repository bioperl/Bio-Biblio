package Bio::Biblio::IO;

use utf8;
use strict;
use warnings;
use Symbol;

use parent qw(Bio::Root::Root Bio::Root::IO);

# ABSTRACT: Handling the bibliographic references
# AUTHOR:   Martin Senger <senger@ebi.ac.uk>
# OWNER:    2002 European Bioinformatics Institute
# LICENSE:  Perl_5

=head1 SYNOPSIS

    use Bio::Biblio::IO;

    # getting citations from a file
    $in = Bio::Biblio::IO->new ('-file' => 'myfile.xml' ,
                                '-format' => 'medlinexml');
  # --- OR ---

    # getting citations from a string
    $in = Bio::Biblio::IO->new ('-data' => '<MedlineCitation>...</MedlineCitation>' ,
                                '-format' => 'medlinexml');
  #--- OR ---

    # getting citations from a string if IO::String is installed
    use IO::String;
    $in = Bio::Biblio::IO->new ('-fh' => IO::String->new ($citation),
                                '-format' => 'medlinexml');

    $in = Bio::Biblio::IO->new(-fh => $io_handle , '-format' => 'medlinexml');

  #--- OR ---

    # getting citations from any IO handler
    $in = Bio::Biblio::IO->new('-fh' => $io_handle ,
                               '-format' => 'medlinexml');


    # now, having $in, we can read all citations
    while ( my $citation = $in->next_bibref() ) {
        &do_something_with_citation ($citation);
    }

  #--- OR ---

    # again reading all citation but now a callback defined in your
    # code is used (note that the reading starts already when new()
    # is called)
    $io = Bio::Biblio::IO->new('-format'   => 'medlinexml',
                               '-file'     => $testfile,
                               '-callback' => \&callback);
    sub callback {
        my $citation = shift;
        print $citation->{'_identifier'} . "\n";
    }

  #Now, to actually get a citation in an XML format,
  #use I<Bio::Biblio> module which returns an XML string:

    use Bio::Biblio;
    use Bio::Biblio::IO;
    my $xml = Bio::Biblio->new->get_by_id ('12368254');
    my $reader = Bio::Biblio::IO->new ('-data' => $xml,
                                       '-format' => 'medlinexml');

    while (my $citation = $reader->next_bibref()) {
       #... do something here with $citation
       }

  #And, finally, the resulting citation can be received in different
  #output formats:

    $io = Bio::Biblio::IO->new('-format' => 'medlinexml',
                               '-result' => 'raw');
  #--- OR ---

    $io = Bio::Biblio::IO->new('-format' => 'medlinexml',
                               '-result' => 'medline2ref');

  #--- OR ---

    $io = Bio::Biblio::IO->new('-format' => 'pubmedxml',
                               '-result' => 'pubmed2ref');

=head1 DESCRIPTION

Bio::Biblio::IO is a handler module for accessing bibliographic
citations. The citations can be in different formats - assuming that
there is a corresponding module knowing that format in Bio::Biblio::IO
directory (e.g. Bio::Biblio::IO::medlinexml). The format (and the
module name) is given by the argument I<-format>.

Once an instance of C<Bio::Biblio::IO> class is available, the
citations can be read by calling repeatedly method I<next_bibref>:

    while (my $citation = $reader->next_bibref()) {
       ... do something here with $citation
       }

However, this may imply that all citations were already read into the
memory. If you expect a huge amount of citations to be read, you may
choose a I<callback> option. Your subroutine is specified in the
C<new()> method and is called every time a new citation is available
(see an example above in SYNOPSIS).

The citations returned by I<next_bibref> or given to your callback
routine can be of different formats depending on the argument
I<-result>. One result type is I<raw> and it is represented by a
simple, not blessed hash table:

    $io = Bio::Biblio::IO->new('-result' => 'raw');

What other result formats are available depends on the module who
reads the citations in the first place. At the moment, the following
ones are available:

    $io = Bio::Biblio::IO->new('-result' => 'medline2ref');

This is a default result format for reading citations by the
I<medlinexml> module. The C<medlinexml> module is again the default
one. Which means that you can almost omit arguments (you still need to
say where the citations come from):

    $io = Bio::Biblio::IO->new('-file' => 'data/medline_data.xml');

Another result format available is for PUBMED citations (which is a
super-set of the MEDLINE citations having few more tags):

    $io = Bio::Biblio::IO->new('-format' => 'pubmedxml',
                               '-result' => 'pubmed2ref',
                               '-data'   => $citation);

Or, because C<pubmed2ref> is a default one for PUBMED citations, you can say just:

    $io = Bio::Biblio::IO->new('-format' => 'pubmedxml',
                               '-data'   => $citation);

Both C<medline2ref> and C<pubmed2ref> results are objects defined in
the directory C<Bio::Biblio>.

=head1 SEE ALSO

=for :list
* An example script F<eg/biblio-soap.pl>
It has many options and its own help.  The relevant options to this IO module
are C<-f> (specifying what file to read) and C<-O> (specifying what result
format to achieve).
* OpenBQS home page
http://www.ebi.ac.uk/~senger/openbqs/
* Comments to the Perl client
http://www.ebi.ac.uk/~senger/openbqs/Client_perl.html
=cut

my $entry = 0;

=method new
=cut

sub new {
    my ($caller, @args) = @_;
    my $class = ref ($caller) || $caller;

    # if $caller is an object, or if it is an underlying
    # 'real-work-doing' class (e.g. Bio::Biblio::IO::medlinexml) then
    # we want to call SUPER to create and bless an object
    if( $class =~ /Bio::Biblio::IO::(\S+)/ ) {
        my ($self) = $class->SUPER::new (@args);
        $self->_initialize (@args);
        return $self;

    # this is called only the first time when somebody calls: 'new
    # Bio::Biblio::IO (...)', and it actually loads a 'real-work-doing'
    # module and call this new() method again (unless the loaded
    # module has its own new() method)
    } else {
        my %param = @args;
        @param{ map { lc $_ } keys %param } = values %param; # lowercase keys
        my $format = $param{'-format'} ||
            $class->_guess_format( $param{-file} || $ARGV[0] ) ||
                'medlinexml';
        $format = "\L$format";  # normalize capitalization to lower case

        # load module with the real implementation - as defined in $format
        return unless (&_load_format_module ($format));

        # this will call this same method new() - but rather its
        # upper (object) branche
        return "Bio::Biblio::IO::$format"->new(@args);
    }
}

=method newFh
=cut

sub newFh {
    my $class = shift;
    return unless my $self = $class->new(@_);
    return $self->fh;
}

=attr fh
=cut

sub fh {
    my $self = shift;
    my $class = ref($self) || $self;
    my $s = Symbol::gensym;
    tie $$s,$class,$self;
    return $s;
}

# _initialize is chained for all Bio::Biblio::IO classes

=internal _initialize
=cut

sub _initialize {
    my ($self, @args) = @_;
    # initialize the IO part
    $self->_initialize_io (@args);
}

=method next_bibref

 Usage   : $citation = stream->next_bibref
 Function: Reads the next citation object from the stream and returns it.
 Returns : a Bio::Biblio::Ref citation object, or something else
           (depending on the '-result' argument given in the 'new()'
           method).
 Args    : none

=cut

sub next_bibref {
    my ($self) = shift;
    $self->throw ("Sorry, you cannot read from a generic Bio::Biblio::IO object.");
}

# -----------------------------------------------------------------------------

=internal _load_format_module

 Usage   : $class->_load_format_module ($format)
 Returns : 1 on success, undef on failure
 Args    : 'format' should contain the last part of the
           name of a module who does the real implementation

It does (in run-time) a similar thing as

   require Bio::Biblio::IO::$format

It throws an exception if it fails to find and load the module
(for example, because of the compilation errors in the module).

=cut

sub _load_format_module {
    my ($format) = @_;
    my ($module, $load, $m);

    $module = "_<Bio/Biblio/IO/$format.pm";
    $load = "Bio/Biblio/IO/$format.pm";

    return 1 if $main::{$module};
    eval {
        require $load;
    };
    if ( $@ ) {
        Bio::Root::Root->throw (<<END);
$load: $format cannot be found or loaded
Exception $@
For more information about the Biblio system please see the Bio::Biblio::IO docs.
END
        ;
        return;
    }
    return 1;
}

=internal _guess_format

 Usage   : $class->_guess_format ($filename)
 Returns : string with a guessed format of the input data (e.g. 'medlinexml')
 Args    : a file name whose extension can help to guess its format

It makes an expert guess what kind of data are in the given file
(but be prepare that $filename may be empty).

=cut

sub _guess_format {
    my $class = shift;
    return unless $_ = shift;
    return 'medlinexml'   if (/\.(xml|medlinexml)$/i);
    return;
}

=method DESTROY
=cut

sub DESTROY {
    my $self = shift;

    $self->close();
}

=method TIEHANDLE
=cut

sub TIEHANDLE {
    my ($class,$val) = @_;
    return bless {'biblio' => $val}, $class;
}

=method READLINE
=cut

sub READLINE {
    my $self = shift;
    return $self->{'biblio'}->next_bibref() unless wantarray;
    my (@list, $obj);
    push @list, $obj while $obj = $self->{'biblio'}->next_bibref();
    return @list;
}

1;
