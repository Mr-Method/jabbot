use v5.18;

package Jabbot::Front::Telegram;
use strict;
use warnings;

use Jabbot;
use Jabbot::RemoteCore;

use Encode qw(encode_utf8);
use List::Util qw(max);

use Mojo::JSON qw(decode_json);
use Mojo::IOLoop;
use WWW::Telegram::BotAPI;

my $API_TELEGRAM = WWW::Telegram::BotAPI->new (token => Jabbot->config->{telegram}{token}, async => 1);

sub send_reply {
    state $jabbot = Jabbot::RemoteCore->new();
    my ($chat_id, $text) = @_;

    my $answer = $jabbot->answer(q => $text);
    my $reply_text = $answer->{body};

    $API_TELEGRAM->api_request(
        sendMessage => {
            chat_id => $chat_id,
            text    => $reply_text,
        }, sub {
            my ($ua, $tx) = @_;
            return unless $tx->success;
            say encode_utf8 ">> $reply_text";
        }
    );
}

sub get_updates {
    my $RECV = {};
    state $max_update_id = -1;

    $API_TELEGRAM->api_request(
        'getUpdates',
        { offset => $max_update_id + 1 },
        sub {
            my ($ua, $tx) = @_;
            return unless $tx->success;

            say time . ": " . $tx->res->body;

            my $res = decode_json( $tx->res->body );
            for (@{$res->{result}}) {
                $RECV->{updates}{ $_->{update_id} } = { update => $_ };
                $max_update_id = max($max_update_id, $_->{update_id});

                say encode_utf8 "<< $_->{message}{text}";
                send_reply( $_->{message}{chat}{id}, $_->{message}{text} );
            }

            say "="x40;
        }
    );
}

$API_TELEGRAM->api_request(
    'getMe',
    sub {
        my ($ua, $tx) = @_;
        die unless $tx->success;
        say "getMe: " . $tx->res->body;

        my $interval = Jabbot->config->{telegram}{poll_interval} // 15;
        say "poll interval = $interval";

        Mojo::IOLoop->recurring( $interval  => \&get_updates );
    }
);


use Mojolicious::Lite;

get '/' => sub {
    my $c = shift;
    $c->render(json => {
        name     => "jabbot-telegramd",
    });    
};

# Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
app->start;

