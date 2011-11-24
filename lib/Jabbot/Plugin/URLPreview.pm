package Jabbot::Plugin::URLPreview;
use warnings;
use strict;
use Jabbot::Plugin;
use LWP::Simple;
use Web::Query;
use Try::Tiny;

sub can_answer {
    my ($text) = @args;
    return $text =~ m{https?://};  # match a url pattern ?
}

sub answer {
    my ($text) = @args;
    my ($url) = ($text =~ m{(https?://\S+)});



    # TODO: 
    #  * do something with metacpan or search.cpan.org ?
    #  * consider circumstances of large file or non-html content.
    #     my $request = HTTP::Request->new(HEAD => $url);
    #     my $response = $ua->request($request);
    my $title;
    try {
        wq($url)->find('title')
                ->each(sub {
                    my $i = shift;
                    $title = $_->text;
                });
        my $reply = sprintf '=>  %s', $title;
        return { content => $reply, confidence => 1 };
    } catch {

    };
}

1;