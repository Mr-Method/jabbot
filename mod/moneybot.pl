#!/usr/local/bin/perl

BEGIN { push @INC, "../lib"; }

use strict;
use Jabbot::Lib;
use Jabbot::ModLib;

qq{����(USD) �s�x��(NTD) ���(JPY) ���(HKD) �H����(MCY) �^��(GRP) �ڬw�q�f(ECU) �[���j��(CAD) �D��(AUD) ����(THB) �s�[�Y��(SGD) �n���G(KOW) �L����(IDR) ���Ӧ�ȹ�(MYR) ��߻��ܯ�(PHP) �L�׿c��(INR) ����(SAR) ��¯S��(KWD) ���¹�(NOK) ��h�k��(SWF) ���J��(SEK) �����J��(DMK) �ڦ��(BRC) ������ܯ�(MEP) ���ڧʩܯ�(ARS) ���Q�ܯ�(CLP) �e�示�Թ�(VEB) �n�D��(ZAR) �Xù���c��(RUR) �æ�����(NZD)  };

my %cname = (USD => "����", NTD => "�s�x��", JPY => "���", HKD => "���",
	     MCY => "�H����", GRP => "�^��", ECU => "�ڬw�q�f", CAD => "�[���j��",
	     AUD => "�D��", THB => "����", SGD => "�s�[�Y��", KOW => "�n���G",
	     IDR => "�L����", MYR => "���Ӧ�ȹ�", PHP => "��߻��ܯ�",
	     INR => "�L�׿c��", SAR => "����", KWD => "��¯S��", NOK => "���¹�",
	     SWF => "��h�k��", SEK => "���J��", DMK => "�����J��", BRC => "�ڦ��",
	     MEP => "������ܯ�", ARS => "���ڧʩܯ�", CLP => "���Q�ܯ�",
	     VEB => "�e�示�Թ�", ZAR => "�n�D��", RUR => "�Xù���c��",
	     NZD => "�æ�����" );

my %coin = (
   USD => "1", NTD => "2", JPY => "3", HKD => "4", MCY => "5",
   GRP => "6", ECU => "7", CAD => "8", AUD => "9", THB => "10",
   SGD => "11", KOW => "12", IDR => "13", MYR => "14", PHP => "15",
   INR => "16", SAR => "17", KWD => "18", NOK => "19", SWF => "20",
   SEK => "21", DMK => "22", BRC => "23", MEP => "24", ARS => "25",
   CLP => "26", VEB => "27", ZAR => "28", RUR => "29", NZD => "30"
);

my %calias = ( EUR => "ECU", "RMB" => "MCY", "YEN" => "JPY", "CHF" =>"SWF"
	      );

my $s = $MSG{body};
my $reply;
my $priority = 0;
my $to       = $MSG{from};
my $allsymbol = join("|",keys %coin) . "|" . join("|",keys %calias);
my $qmark = '(?:[\s\?]|�H)*';
if ( $s =~ /^([\d\.]+)\s*($allsymbol)\s+to\s+($allsymbol)$qmark$/i ) {
    $reply = get_ex_money($1,$2,$3);
} elsif ( $s =~ /^([\d\.]+)\s*($allsymbol)$qmark$/i ) {
    $reply = get_ex_money($1,$2);
} elsif ( $s =~ /^currency\s+list([\s\?])*?/i ) {
    $reply = "You may ask my to exchange these currency: "
	. join(",", map { $cname{$_}."($_)" } sort keys %cname );
} elsif ( $s =~ /^help (currency|money|exchang)/) {
    $reply =
	'I can do currency exchanging, Example: 10 USD to NTD? , or simply "10 USD"' .
	"\n" .
	'To list all currency, say "currency list" to me';
}

$priority = 10000 if(length($reply) > 0);

my %rmsg = (
    priority => $priority,
    from     => $BOT_NICK,
    to       => $to,
    public   => 1,
    body     => $reply
    );

reply (\%rmsg);

sub get_ex_money {
#     my ($data) =@_;
#     $data =~ s/ //;
#     my @datas = split(/,/,$data);
#     my ($from,$to,$money);
#     if ( $#datas == 2 ) {
#         $from = $datas[0];
#         $to = $datas[1];
#         $money = $datas[2];
#     } elsif ($#datas == 1) {
#         $from = "2"; #default NTD
#         $to = $datas[0];
#         $money = $datas[1];
#     } else {
#         return "usage: money FROM,TO,MONEY";
#    };

    my ($money,$from,$to) = @_;
    $to ||= "NTD"; # Default to NTD
    $from = expand_alias(uc($from));
    $to   = expand_alias(uc($to));
    # Random answer :-/
    while($from eq $to) {
	$to = rand_choose(keys %coin);
    }
    use HTTP::Request::Common qw(GET);
    use LWP::UserAgent;
    my $ua = LWP::UserAgent->new(timeout => 300) or die $!;;
    my $res;
    eval {
        $SIG{ALRM} = sub { die "alarm\n"; };
	alarm(30);
	$res = $ua->request(
		GET 'http://tw.stock.yahoo.com/d/c/ex.php?money='.$money.
		'&select1='.$coin{$from}.'&select2='.$coin{$to}
		);
	alarm(0);
    };
    if($@) {
	die "Connection Timeout";
    }

    if ($res->is_success) {
	my $data = $res->content;
	if ($data =~ /�g�L�p���A([^<]+)/) {
	    my $reStr = $1;
	    $reStr =~ s/&nbsp;/ /igs;
	    $reStr =~ s/  / /igs;
	    return $reStr;
	} else {
	    return "�䤣��";
	};
    }
}

sub expand_alias {
    my $from = shift;
    if(length($calias{$from}) > 0) {
	$from = $calias{$from};
    }
    return $from;
}
