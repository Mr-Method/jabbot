#!/usr/local/bin/perl

BEGIN { push @INC, "../lib"; }

use strict;
use Jabbot::Lib;
use Jabbot::ModLib;
use Jabbot::Lib qw(rand_choose);

my $s = $MSG{body};
my $r;
my $to = $MSG{from};

exit unless($MSG{to} eq $BOT_NICK );

if ($s =~ /����/ ) {
    $r = "���Ȯ�";
} elsif ($s =~ /^��.+$/ ) {
    $r = "���N���Ȯ�F~~";
}

reply({
    priority => 10,
    from => $BOT_NICK,
    to   => $to, 
    body => $r
    });

