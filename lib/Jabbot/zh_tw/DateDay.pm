package Jabbot::zh_tw::DateDay;
use Jabbot::Plugin -Base;
use Date::Day;

const class_id => 'zhtw_dateday';

my %ZhDay = (
    MON => "�P���@",
    TUE => "�P���G",
    WED => "�P���T",
    THU => "�P���|",
    FRI => "�P����",
    SAT => "�P����",
    SUN => "�P����",
    );

sub process {
    my $msg = shift->text;
    my $reply;
    if($msg =~ /^(.*��)(?:�O)?(?:�P���X)?/) {
        my $target = $1;
        my $p = '(.+)��';
        my $p0 = '(.+)��(.+)��';
        my $p1 = '(.+)�~(.+)��(.+)��';
        my @now = localtime(time);
        if ($target =~ /$p1/) {
            my ($o,$m,$n) = ($1,$2,$3);
            $self->trim($m,$n,$o);
            my $result = &day($m,$n,$o);
            $reply = $ZhDay{$result};
        } elsif ($target =~ /$p0/) {
            my ($m,$n) = ($1,$2);
            $self->trim($m,$n);
            my $result = &day($m,$n,$now[5]+1900);
            $reply = $ZhDay{$result};
        } elsif($target =~ /$p/) {
            my $n = $1;
            $self->trim($n);
            my $result = &day($now[4]+1,$n,$now[5]+1900);
            $reply = $ZhDay{$result};
        }
        $reply = "${target}�O${reply}"
            if(defined $reply && rand(100) > 60);
    }
    $self->reply($reply,10000);
}
