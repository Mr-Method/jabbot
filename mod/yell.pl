#!/usr/local/bin/perl

BEGIN { push @INC, "../lib"; }

use strict;
use Jabbot::Lib;
use Jabbot::ModLib;

if (rand(5) > 2) {
#	print STDERR "exit\n";
	exit(0);
}

my $s = $MSG{body};
my $r;

if ($s =~ /�g/ ) {
    $r = "�g�I";
} elsif ($s =~ /�u(?:��|�O)*(.+)(?:[\.\s]|�A|�C)*$/) {
    $r = rand_choose("$1�I","�O��","�S��","");
} elsif ($s =~ /�S(.+)(?:[\.\s]|�A|�C)*$/) {
    $r = rand_choose("�u���W","�S���o","�W��","������S$1?");
} elsif ($s =~ /:\(/) {
    $r = rand_choose("�O���L",":-/");
} elsif ($s =~ /:[Pp]/) {
    $r = rand_choose(":p");
} elsif ($s =~ /\.{3,}\s*$/) {
    $r = rand_choose("hmmm...","��...");
} elsif ($s =~ /�W/) {
    $r =  rand_choose("�[�o�I");
} elsif ($s =~ /\bping\b/i) {
    $r = rand_choose("pong","PONG","pong pong pong","�I");
}

my $to = $MSG{from};

unless($MSG{to} eq $BOT_NICK) {
    undef $to;
}

reply({
    priority => 0,
    from     => $BOT_NICK ,
    to       => $to,
    body     => $r
    });

