#!/usr/local/bin/perl

BEGIN { push @INC, "../lib"; }

use strict;
use DB_File;
use Jabbot::Lib;
use Jabbot::ModLib;


my $probability = 0;
my $s = $MSG{body};
my ($reply,$hit);
my $priority = 0;
my @cofe = ("Expresso", "Expresso Light",
	      "Expresso Con Panna", "Expresso Macchiato",
	      "Cappuccino", "Caffe Latte", "Short Latte",
	      "Caffe Latte Macchiato", "Caffe Mochaccino",
	      "Caffe Mocha", "Baileys Cappuccino",
	      "Kahlua Cappuccino", "Ice Expresso Light",
	      "Cozy Ice Coffee", "Ice Cappuccino",
	      "Ice Caffe Latte", "Ice Caffe Latte Macchiato",
	      "Ice Caffe Mocha", "Ice Expresso with ice cream",
	      "Ice cream coffee",
	);

my @nowtime = localtime(time);
my $gametime = 0;
if($nowtime[2] > 12) {
    $gametime = 1;
}

my %cozygame;
tie %cozygame, 'DB_File', "${DB_DIR}/cozygame.db", O_CREAT|O_RDWR ;
my $nowdate = "$nowtime[3] $nowtime[4] $nowtime[5]";
my $nowmd = ($nowtime[4] + 1)  ."/$nowtime[3]";
my $nowhm = "$nowtime[2]:$nowtime[1]:$nowtime[0]";

unless ( $cozygame{"__date__"} eq $nowdate ) {
    foreach(keys %cozygame) {
	$cozygame{$_} = 0;
    }
    $cozygame{"__date__"} = $nowdate;
}

$cozygame{lc($MSG{from})} ||= 0;

# If you are not talking to me, I ignore you.
exit(0) unless($MSG{to} eq $BOT_NICK);

$probability = get_prob();
my $maxgametime = 1;
if($s =~ /^((?:����|�n)*��(?:����)?
           |(?:what\sto\sdrink(?:\stoday)?)
           )(\?|�H)*/x) {
    $reply = rand_choose(@cofe);
    if($probability > 0 ) {
	$hit = 1 if ( (rand(100) < 100 * $probability));
	if($cozygame{lc($MSG{from})} < $maxgametime 
		&& $gametime
	  ) {
	    $cozygame{lc($MSG{from})}++;
#		$hit=1 if($MSG{from} eq "james_");
	    if($hit) {
		$reply .= " *�����F* �i�H�K�O�ϥ� Cozy �����@��";
	    } else {
		$reply .= " (�S����) ";
	    }
	    $reply .= "   (�������v�� $probability )" if ($probability > 0);
	    $reply .= "�A�A���Ѫ��F ". $cozygame{lc($MSG{from})} ." ��"
		if($cozygame{lc($MSG{from})} > 1);
	}
    }
    open(FH,">> ${DB_DIR}/cozygame_record.txt");
    print FH "$nowhm $nowmd , ". lc($MSG{from}) . ", ${reply}\n";
    close(FH);
} elsif($s =~ /^((?:����)?�������v(?:�h��)?(?:[\s\?]|�H)+)$/) {
    if($probability < 0 ) {
        $reply = "�������v���~, henyi.org down";
    } else {
	$reply = "���Ѥ������v�O $probability";
	if($gametime) {
	    $reply .= " (�{�b�i�H��) ";
	} else {
	    $reply .= " (�{�b���઱) ";
	}
	$reply .= "�A�A���Ѫ��F ". $cozygame{lc($MSG{from})} ." ��";
	$reply .= "See also: �uCozy �C���W�h�v";
    }
} elsif($s =~ /^(?:
	    (?:cozy\s*rules)|
	    (?:[Cc][Oo][Zz][Yy]\s*�C���W�h))
	(?:[\s\?]|�H)+$/x) {
    $reply = "�b Cozy ��~�ɶ�(13:00-24:00)���A�B james �b���̮ɡA"
	."�ݧڡu���ѳܤ���v�h���@���������|�]���v�� james �q�^�A" 
	."�Y�Q�i�������A�h�i�H�K�O�ϥκ����@���C(���A���ѩ���@��)"
	."See also: �u���Ѥ������v�v";
} else {
  exit(0);
}
$priority = 10000;
my $to = $MSG{from};

# print STDERR "[whattodo] ($priority) $reply \n";

my %rmsg = (
    priority => $priority,
    from     => $BOT_NICK ,
    to       => $to,
    body     => $reply
    );

reply (\%rmsg);

untie %cozygame;

sub get_prob {
    use Net::Ping;

    my $prob = -1;
    my $p = Net::Ping->new();
    $p->hires();
    my ($ret, $duration, $ip) = $p->ping("henyi.org", 6);
    if ($ret) {
	require LWP::UserAgent;
	my $ua = LWP::UserAgent->new(timeout => 5);
	my $response;

# Timeout mechnism
	eval {
	    $SIG{ALRM} = sub { die"alarm\n"; };
	    alarm(10);
	    $response = $ua->get('http://henyi.org/~james/cozy.txt');
	    alarm(0);
	};
	if($@) {
	    die unless $@ eq "alarm\n";
	}

	if ($response->is_success) {
	    $prob = $response->content;
	    trim_whitespace($prob);
	} else {
	    exit(0);
	}
    }
    $p->close();

    return $prob;
}
