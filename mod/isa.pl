#!/usr/local/bin/perl

BEGIN { push @INC, "../lib"; }

use strict;
use DB_File;
use Encode qw/decode/;

use Jabbot::Lib;
use Jabbot::ModLib;

my $qstring = $MSG{body};

my %isadb;
tie %isadb, 'DB_File', "${DB_DIR}/isa.db", O_CREAT|O_RDWR ;

my $ymodifiers = "�n��|����|�N|�D|�u|�N|�u��|�u";
my $priority = 0;
my $r;

$qstring =~ s/^(.*)�O��\s*(\?|�H)$/�֬O$1�H/;

if ($qstring =~ /^�֬O/) {
	$qstring .= "�H";
}
if($qstring =~ /(\?|�H)$/ ) {
	# Don't reply anything if I'm not been asked.
    	exit(0) unless($MSG{to} eq $BOT_NICK) ;
	$qstring =~ s/(?:\?|�H|\s)+$//;
	if($MSG{to} eq $BOT_NICK) {
		$qstring =~ s/�A/��/g;
	}
	if ($qstring =~ /^�֬O\s*(.*?)\s*$/) {
		$r = _queryWhoIsWhat($qstring);
	} elsif ($qstring =~ /^(��|��)��O(?!����)/) {
		my $q = $qstring;
		$q =~ s/^(.*)�O//;
		$r = _queryWhatIsThat($q);
	} elsif ($qstring =~ /�O(?!����)/) {
		$r = _queryWhatIsWhat($qstring);
	} elsif ($qstring =~ /�O����/) {
		$qstring =~ s/\s*�O����//;
	}
        if(length($isadb{"$qstring"}) > 0) {
		$r = $isadb{"$qstring"};
		$priority = 1000;
	}
} elsif($qstring =~ /^(?:(?:(?:dump|(?:tell me)) all keywords about)|(?:what do you know about))\s+([^\?]+)[\s\?]*$/) {
	my $wanted = quotemeta($1);
	my @iknow = grep { $_ =~ /$wanted/i } keys %isadb;
	if(@iknow) {
	    $r = "�@�@�� " .( $#iknow + 1) ." ��: " . join(" || ", @iknow);
	    $r = "�@�@�� ". ($#iknow + 1) ." ��, ��b�Ӧh�F"
		if (length($r) > 400);
	}
	$r ||= "��ԣ�������D�A�O����";
} elsif($qstring =~ /^(?:dump|(?:tell me)) all about\s+(.*)\s*$/) {
	my $wanted = quotemeta($1);
	my @iknow = grep { $_ =~ /$wanted/i } keys %isadb;
	my $k = scalar(@iknow);
	$k = 3 if $k > 3;
	$r = join("�C", map {$isadb{$_}} (sort { rand() <=> rand() } @iknow)[0..$k]);
	$r = "�Ӧh�F�A�T�ѤT�]������" if (length($r) > 400);
	$r ||= "��ԣ�������D�A�O����";
} elsif($qstring =~ /^forget all about\s+(.*)\s*$/ && $MSG{to} eq $BOT_NICK) {
	my $wanted = quotemeta($1);
	my $n = 0 ;
	map { $n++; delete $isadb{$_} }
	grep { $_ =~ /$wanted/ }
	keys %isadb;
	$r= ($n == 0)? "�õL����P $1 ���������"
	 : "�@�@�� $n ����Ʊq��Ʈw���û��R���F";
} elsif($qstring =~ /(?:anything\s+about\s+)(.*)\s*(\?!!!+)/ && $MSG{to} eq $BOT_NICK) {
	my $wanted = quotemeta($1);
	$r = rand_choose(map {$isadb{$_}} grep { $_ =~ /$wanted/ } keys %isadb);
} elsif($qstring =~ /^forget\s+(.*)$/  && $MSG{to} eq $BOT_NICK) {
	delete $isadb{$1};
	$r= "ok";
} elsif(length($isadb{"$qstring"}) > 0 && rand(20) > 17) {
	$r= $isadb{"$qstring"};
} else {
	$r = do_my_job($qstring);
}

delete $isadb{''};
untie %isadb;

if(length($r) > 0) {
    $priority += 10000;
}

reply({from => $BOT_NICK,
       to   => $MSG{from},
       priority => $priority,
       body => $r});

sub do_my_job {
	my $what = shift;
	strip_meanless_tsi($what);
	if($MSG{to} eq $BOT_NICK) {
		$what =~ s/�A/��/g;
	}
	my @sentances = split(/�C/, $what);
	my $r;
	my @rdb =qw(ok �F�� � ��Ӧp�� �ڪ��D�F ��Ӧp�����I �O��F �ҥH�H);
	my $TOKEN = '(?:�O|��)';
	foreach (@sentances) {
		if (/$TOKEN/) {
			my ($k,$v) = split(/(?:��)?(?:$ymodifiers)?$TOKEN/ , $_, 2);
			$k =~ s/\s+$//;
			if(exists $isadb{"$k"}) {
				$r = "���L�A�ڧکҪ��A$isadb{$k}";
			} else {
				$isadb{"$k"} = $_;
				$r = rand_choose(@rdb);
			}
		} elsif (/(.+)\sis\salso\s(.+)/i) {
			my ($k,$v) = ($1,$2);
			$k =~ s/\s+$//;
			if(length($isadb{$k}) > 0) {
			    $isadb{$k} = $v;
			} else {
			    $isadb{$k} .= " or $v";
			}
			$r = rand_choose(@rdb);
		} elsif (/\s[Ii][Ss]\s/) {
			my ($k,$v) = split(/\s[Ii][Ss]\s/ , $_, 2);
			$k =~ s/\s+$//;
			$isadb{$k} = $_;
			$r = rand_choose(@rdb);
		}
	}
	return $r if($MSG{to} eq $BOT_NICK);
}

sub strip_meanless_tsi {
	$_[0] =~ s/^���(�A|,)*//x ;
	$_[0] =~ s/(?:�a|��)$//x ;
	$_[0];
}

sub _queryWhoIsWhat {
    my $qstring = shift;
    my $r;

    my @fuzzyans;
    my $wanted = $1;
    $wanted =~ s/�O$//;
    if (length($isadb{"$wanted"}) > 0) {
	push @fuzzyans,$wanted;
    }

    $wanted = quotemeta($wanted);
    foreach (keys %isadb) {
	my $realv; $realv = $isadb{"$_"};
	if ( $realv =~ m/$wanted/ ) {
	    push @fuzzyans,$_;
	}
    }
    if(scalar @fuzzyans > 0) {
	my $v = $isadb{rand_choose(@fuzzyans)};
	my $who = undef;
	if ($v =~ /^(.+?)\s*�O$wanted$/) {
	    $who = $1;
	}
	if($who) {
	    $r = $who;
	    $priority = 1000;
	} else {
	    $r = "��ť���L: $v";
	}
    } else {
	$r = "�ڤ����D \@_\@";
    }
    return $r;
}

sub _queryWhatIsThat {
    my $qstring = shift;
    my $realv = $isadb{"$qstring"};
    return $realv|| rand_choose("���M��","�Sť�L","�ڤ]�����D");
}

sub _queryWhatIsWhat {
    my $qstring = shift;
    my $r;
    my ($k,$v) = split(/(?:��)?(?:$ymodifiers)?�O/ , $qstring, 2);
    $k =~ s/\s+$//;
    my $realv; $realv = $isadb{"$k"};
    my ($k2,$v2) = split(/(?:��)?(?:$ymodifiers)?�O/ , $realv, 2);
    if(length($realv) > 0 && length($v) > 0) {
	if ($qstring eq $realv) {
	    $r = "�O��";	
	} elsif ( $v2 =~ m/$v/ || $v =~ m/$v2/ ) {
	    $r = rand_choose("�n��","����","�i��")
		. rand_choose("�O","")
		. rand_choose("�a","��","�O");
	} else {
	    $r = rand_choose("���O�a�H","�d����","���O�o�ˤl��","�ä��O","�O�ܡH");
	}	
    }
    return $r;
}

