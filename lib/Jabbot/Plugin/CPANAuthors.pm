package Jabbot::Plugin::CPANAuthors;
use v5.12;
use Object::Tiny;

use Acme::CPANAuthors;
use WWW::Shorten qw(TinyURL);
use CHI;

sub can_answer {
    my ($self, $message) = @_;
    my $text = $message->{body};
    return 1 if $text =~ /!cpan\s*/i;
}

sub answer {
    my ($self, $message) = @_;
    my $text = $message->{body};
    $text =~ s{\s*!cpan\s*}{};

    my $reply = "Unrecognized command: !cpan $text";

    # country
    if($text =~ /^(?<COUNTRY>\w+)\s+authors/ ) {
        my $country = ucfirst $+{COUNTRY};
        my $acme_authors = $self->_get_country_authors( $country );
        return { score => 1, body => "there is no such module for $country" } unless $acme_authors;

        $reply = qq!There are @{[  $acme_authors->count ]} in $country. They are !;
        $reply .= join( ', ' , map { $_ } keys %$acme_authors ) . ' ..etc';
    }

    # id
    elsif( $text =~ /^author\s+(?<AUTHOR_ID>\w+)/ ) {
        my $author_id = uc( $+{AUTHOR_ID} );

        my $cache = CHI->new(
            driver => "Memory",
            namespace => "jabbot_plugin_cpan_authors",
            global => 1,
            expires_in => '10 days'
        );

        $reply = $cache->compute($author_id, {}, sub { cpanauthor_info($author_id) });
    }

    return { body => $reply, score => 1 };
}

sub _get_country_authors {
    my ($self, $country) = @_;
    $country = ucfirst $country;
    $country =~ s/^Taiwan$/Taiwanese/;  # patch
    my $acme_authors = Acme::CPANAuthors->new($country);  # taiwanese
    return unless  $acme_authors ;
}


sub cpanauthor_info {
    my ($author_id) = @_;

    my @authors = Acme::CPANAuthors->look_for($author_id);

    my $reply = "author not found";

    for my $author (@authors) {
        $reply .= sprintf("%s (%s) belongs to %s. ",
                          $author->{id}, $author->{name}, $author->{category});

        my $acme_authors = Acme::CPANAuthors->new( $author->{category} );
        my @dists = $acme_authors->distributions( $author->{id} );

        $reply .= sprintf(" %s has %d dists." , $author->{id} , scalar @dists );

        my $url = makeashorterlink( $acme_authors->avatar_url( $author->{id} ) );
        $reply .= sprintf(" %s looks like this: %s", $author->{id} , $acme_authors->avatar_url( $author->{id} ) );
        $reply .= "\n";
    }

    return $reply;
}

1;
