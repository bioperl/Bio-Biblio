package Bio::Biblio::IO::pubmed2ref;
use utf8;
use strict;
use warnings;

use parent qw(Bio::Biblio::IO::medline2ref);

# ABSTRACT: a converter of a raw hash to PUBMED citations
# AUTHOR:   Martin Senger <senger@ebi.ac.uk>
# OWNER:    2002 European Bioinformatics Institute
# LICENSE:  Perl_5

=head1 SYNOPSIS

 # to be written

=head1 DESCRIPTION

 # to be written

=cut

# ---------------------------------------------------------------------
#
#   Here is the core...
#
# ---------------------------------------------------------------------
=internal _load_instance
=cut

sub _load_instance {
    my ($self, $source) = @_;

    my $result;
    my $article = $$source{'article'};
    if (defined $article) {
        if (defined $$article{'journal'}) {
            $result = $self->_new_instance ('Bio::Biblio::PubmedJournalArticle');
            $result->type ('JournalArticle');
        } elsif (defined $$article{'book'}) {
            $result = $self->_new_instance ('Bio::Biblio::PubmedBookArticle');
            $result->type ('BookArticle');
        } else {
            $result->type ('PubmedArticle');
        }
    }
    $result = $self->_new_instance ('Bio::Biblio::Ref') unless defined $result;
    return $result;
}

=method convert
=cut

sub convert {
    my ($self, $source) = @_;
    my $result = $self->SUPER::convert ($source->{'Citation'});

    # here we do PUBMED's specific stuff
    my $pubmed_data = $$source{'PubmedData'};
    if (defined $pubmed_data) {

        # ... just take it (perhaps rename it)
        $result->pubmed_status ($$pubmed_data{'publicationStatus'}) if defined $$pubmed_data{'publicationStatus'};
        $result->pubmed_provider_id ($$pubmed_data{'providerId'}) if defined $$pubmed_data{'providerId'};
        $result->pubmed_article_id_list ($$pubmed_data{'pubmedArticleIds'}) if defined $$pubmed_data{'pubmedArticleIds'};
        $result->pubmed_url_list ($$pubmed_data{'pubmedURLs'}) if defined $$pubmed_data{'pubmedURLs'};

        # ... put all dates from all 'histories' into one array
        if (defined $$pubmed_data{'histories'}) {
            my @history_list;
            foreach my $history ( @{ $$pubmed_data{'histories'} } ) {
                my $ra_pub_dates = $$history{'pubDates'};
                foreach my $pub_date ( @{ $ra_pub_dates } ) {
                    my %history = ();
                    my $converted_date = &Bio::Biblio::IO::medline2ref::_convert_date ($pub_date);
                    $history{'date'} = $converted_date if defined $converted_date;
                    $history{'pub_status'} = $$pub_date{'pubStatus'} if defined $$pub_date{'pubStatus'};
                    push (@history_list, \%history);
                }
            }
            $result->pubmed_history_list (\@history_list);
        }
    }

    # Done!
    return $result;
}

1;
