package Jabbot::Front::IRC;
use 5.012;
use strict;
use utf8;
use DDP;

use Jabbot;
use Jabbot::RemoteCore;

use IRC::Utils ();
use Mojolicious::Lite;
use Mojo::IRC::UA;
use Mojo::IOLoop;
use Mojo::IOLoop::Delay;

my $IRC_CLIENTS = {};

sub init_irc_client {
    my ($config) = @_;
    state $jabbot = Jabbot::RemoteCore->new;

    my $nick = $config->{nick};

    my $irc = Mojo::IRC::UA->new(
        nick => $config->{nick},
        user => $config->{nick},
        server => $config->{server} . ":" . $config->{port},
    );

    $irc->on(
        error => sub {
            my ($self, $message) = @_;
            p($message);
        });

    $irc->on(
        irc_join => sub {
            my($self, $message) = @_;
            warn "yay! i joined $message->{params}[0]";
        });

    $irc->on(
        irc_privmsg => sub {
            my($self, $message) = @_;
            my $from_nick = IRC::Utils::parse_user($message->{prefix});
            return unless $from_nick;
            return if $from_nick =~ /${nick}_*/;
            my ($channel, $message_text) = @{$message->{params}};
            my ($message_text_without_my_nick_name) = $message_text =~ m/\A ${nick} [,:\s]+ (.+) \z/xmas;
            return unless $message_text_without_my_nick_name;
            my $answer = $jabbot->answer(q => $message_text_without_my_nick_name);
            my $reply_text = $answer->{body};
            $self->write(PRIVMSG => $channel, ":${from_nick}: $reply_text", sub {});
        });

    $irc->on(
        irc_rpl_welcome => sub {
            for (@{$config->{channels}}) {
                my ($channel, $key) = ref($_) ? @$_ : ($_);
                $channel = "#${channel}" unless index($channel, "#") == 0;
                say "-- connected, join $channel";
                $irc->write(join => $channel, $key||());
            }});

    $irc->register_default_event_handlers;
    $irc->connect(sub {});
    return $irc;
}

get '/' => sub {
    my $c = shift;
    $c->render(json => {
        name     => "jabbot-ircbotd",
    });
};

my $networks = Jabbot->config->{irc}{networks};
for (keys %$networks) {
    my $config = $networks->{$_};
    $config->{name} = $_;
    $config->{nick} ||= (Jabbot->config->{nick} || "jabbot_$$");
    say "--- Init IRC Client for network $_";
    $IRC_CLIENTS->{$_} = init_irc_client($config);
}

app->start;
