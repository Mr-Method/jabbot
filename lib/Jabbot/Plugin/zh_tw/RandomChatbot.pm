package Jabbot::Plugin::zh_tw::RandomChatbot;
use v5.18;
use utf8;
use Object::Tiny qw(core);

use Acme::Lingua::ZH::Remix 0.90;

sub can_answer {
    my ($self, $text) = @_;
    return (length($text) > 2);
}

sub answer {
    my ($self, $text) = @_;
    $self->{remix} ||= Acme::Lingua::ZH::Remix->new;
    return {
        body  => $self->{remix}->random_sentence,
        score => 0
    }
}

1;
