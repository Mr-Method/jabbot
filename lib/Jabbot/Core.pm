package Jabbot::Core;
use v5.12;
use strict;
use utf8;
use encoding 'utf8';
use JSON qw(to_json);
use UNIVERSAL::require;
use Jabbot;
use Try::Tiny;

use AnyEvent;
use AnyEvent::MP;
use AnyEvent::MP::Global;

sub new {
    state $core;

    return $core if $core;

    my $class = shift;

    my $self = bless {}, $class;
    $self->{plugins} = [];

    for my $plugin (map { "Jabbot::Plugin::$_"} @{Jabbot->config->{plugins}}) {
        unless ($plugin->require) {
            warn "* $plugin failed to be loaded.\n";
            next;
        }

        unless ($plugin->can('can_answer') && $plugin->can('answer') &&
            $plugin->can('can_answer') != \&Jabbot::Plugin::can_answer &&
            $plugin->can('answer')     != \&Jabbot::Plugin::answer) {
            warn "* $plugin not loaded due to the lack of 'can_answer' or 'answer' method\n";
            next;
        }

        push @{ $self->{plugins} }, $plugin->new( core => $self );
        warn "* LOAD $plugin\n";
    }

    $core = $self;
    return $self;
}

sub answer {
    my ($self, %args) = @_;
    return $self->answers(%args)->[0];
}

sub answers {
    my ($self, %args) = @_;
    my @answers;
    my $q = $args{question};

    for my $plugin (@{$self->{plugins}}) {
        if ($plugin->can_answer($q, \%args)) {
            try {
                my $a = $plugin->answer($q, \%args);
                if (ref $a eq 'HASH') {
                    $a->{plugin} = ref $plugin;
                    $a->{plugin} =~ s/^Jabbot::Plugin:://;
                    push @answers, $a;
                }
            }
        }
    }
    return [sort { $b->{confidence} <=> $a->{confidence} } @answers];
}

sub run {
    my $self = Jabbot::Core->new;

    configure profile => "jabbot-core";

    grp_reg 'jabbot-core' => rcv(
        port,
        action => sub {
            my ($data, $reply_port) = @_;
            my $reply_ports = $reply_port ? [ $reply_port ] : grp_get($data->{node});
            my $name = $data->{name};
            return unless $reply_ports && $self->can($name);

            my $reply = $self->$name(%{$data->{args}});

            snd $_, reply => {
                $name   => $reply,
                network => $data->{args}{network},
                channel => $data->{args}{channel},
                from    => $data->{args}{from},
                to_me   => $data->{args}{to_me},
            } for @$reply_ports;
        }
    );

    AnyEvent->condvar->recv;
}

1;
