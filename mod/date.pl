#!/usr/local/bin/perl

BEGIN { push @INC, "../lib"; }

use strict;
use Jabbot::Lib;
use Jabbot::ModLib;

$_ = $MSG{body};
my $reply;

my %ZhDay = (
    MON => "�P���@",
    TUE => "�P���G",
    WED => "�P���T",
    THU => "�P���|",
    FRI => "�P����",
    SAT => "�P����",
    SUN => "�P����",
    );

if(/^(.*)(?:�O)?�P���X/) {
    my $target = $1;
    use Date::Day;
 
    my $p = '(.+)��';
    my $p0 = '(.+)��(.+)��';
    my $p1 = '(.+)�~(.+)��(.+)��';
    my @now = localtime(time);
    if ($target =~ /$p1/) {
	my ($o,$m,$n) = ($1,$2,$3);
	trim_whitespace($m,$n,$o);
	my $result = &day($m,$n,$o);
	$reply = $ZhDay{$result};
    } elsif ($target =~ /$p0/) {
	my ($m,$n) = ($1,$2);
	trim_whitespace($m,$n);
	my $result = &day($m,$n,$now[5]+1900);
	$reply = $ZhDay{$result};
    } elsif($target =~ /$p/) {
	my $n = $1;
	trim_whitespace($n);
	my $result = &day($now[4]+1,$n,$now[5]+1900);
	$reply = $ZhDay{$result};
    }
} elsif (/^(�W�W|�U�U|�o��|�W|�U|�o)�P��(..)�X��/) {
} else {
    exit(0);
}

my $priority = 10000 if(length($reply) > 0);

my %rmsg = (
    priority => $priority,
    from     => $BOT_NICK,
    to       => "",
    public   => 1,
    body     => $reply
    );

reply (\%rmsg);

