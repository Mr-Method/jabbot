package Jabbot::zh_tw::CurrencyConvert;
use Jabbot::Plugin -Base;
use HTTP::Request::Common qw(GET);
use LWP::UserAgent;
use Encode;
use List::Util qw(shuffle);

# This .pm has to be in big5 otherwise http request failed.

const class_id => 'zhtw_currencyconvert';

# qq{����(USD) �s�x��(NTD) ���(JPY) ���(HKD) �H����(MCY) �^��(GRP) �ڬw�q�f(ECU) �[���j��(CAD) �D��(AUD) ����(THB) �s�[�Y��(SGD) �n���G(KOW) �L����(IDR) ���Ӧ�ȹ�(MYR) ��߻��ܯ�(PHP) �L�׿c��(INR) ����(SAR) ��¯S��(KWD) ���¹�(NOK) ��h�k��(SWF) ���J��(SEK) �����J��(DMK) �ڦ��(BRC) ������ܯ�(MEP) ���ڧʩܯ�(ARS) ���Q�ܯ�(CLP) �e�示�Թ�(VEB) �n�D��(ZAR) �Xù���c��(RUR) �æ�����(NZD)  };

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

my %calias = ( GBP => 'GRP', EUR => "ECU", "RMB" => "MCY", "YEN" => "JPY", "CHF" =>"SWF");


sub process {
    my $s = shift->text;
    my $reply;
    my $allsymbol = join("|",keys %coin) . "|" . join("|",keys %calias);
    my $qmark = '(?:[\s\?]|�H)*';
    if ( $s =~ /^([\d\.\+\-\*\/]+)\s*($allsymbol)\s+to\s+($allsymbol)$qmark$/i ) {
        $reply = $self->get_ex_money($1,$2,$3);
    } elsif ( $s =~ /^([\d\.\+\-\*\/]+)\s*($allsymbol)$qmark$/i ) {
        $reply = $self->get_ex_money($1,$2);
    } elsif ( $s =~ /^currency\s+list([\s\?])*?/i ) {
        $reply = "You may ask my to exchange these currency: "
            . join(",", map { $cname{$_}."($_)" } sort keys %cname );
    } elsif ($s =~ m{help (currency|money|exchang)} ) {
        $reply =
            qq{I can do currency exchanging, Example: 10 USD to NTD?, or simply "10 USD". To list all currency, say "currency list" to me};
    }
    $reply = Encode::decode('big5',$reply);
    $self->reply($reply,1);
}

sub get_ex_money {
    my ($money,$from,$to) = @_;
    $to ||= "NTD"; # Default to NTD
    $from = $self->expand_alias(uc($from));
    $to   = $self->expand_alias(uc($to));
    eval"\$money = $money";
    # Random answer :-/
    while($from eq $to) {$to = (shuffle(keys %coin))[0];}
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
	return "Yahoo Connection Timeout";
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
    if(defined $calias{$from}) {
	$from = $calias{$from};
    }
    return $from;
}
