#!/usr/local/bin/perl

BEGIN { push @INC, "../lib"; }

use strict;
use Jabbot::Lib;
use Jabbot::ModLib;

my $s = $MSG{body};
my $reply;
if($s =~ /^lotto$/i) {
  $reply = join(",", sort{$a<=>$b}(sort{rand()<=>rand()}(1..42))[0..5]);
} elsif($s =~ /^\Q�|�P�m\E$/) {
  print STDERR "Matched [$s]\n";
  $_ = sprintf"%04d",int(rand(10000));
  $reply = sprintf("���m %s, �e�T�m %s, ��T�m %s, �e��m %s, ���m %s.",
	  $_, substr($_,0,3), substr($_,-3,3), m/(\d\d)(\d\d)/);
}

exit(0) unless(length($reply) > 0);

reply({
    priority => 10000,
    from     => $BOT_NICK ,
    to       => $MSG{from},
    body     => $reply
    });

