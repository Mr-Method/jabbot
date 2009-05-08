package Jabbot::FrontEnd::IRC;
use strict;
use warnings;
use Jabbot::FrontEnd -base;
use POE qw(Session
           Component::IRC::State
           Component::IRC::Plugin::AutoJoin
           Component::IRC::Plugin::Connector
           Component::IKC::Server
           Component::IKC::Specifier);

use Encode qw(encode decode from_to);

my $config;
my $self;

sub process {
    $self= shift;
    $config = $self->hub->config->{irc};

    POE::Component::IKC::Server->spawn(
        port => $config->{frontend_port},
        name => $self->hub->config->{nick}
    );

    for my $network (@{$config->{networks}}) {
        my $irc = POE::Component::IRC::State->spawn(
            alias => "irc_frontend_${network}",
            Nick   => $self->hub->config->{nick},
            Server => $config->{$network}{server},
            Port   => $config->{$network}{port},
       ) or die "Couldn't create IRC POE session: $!";

        POE::Session->create(
            heap => {
                irc => $irc,
                network => $network,
            },
            inline_states => {
                irc_disconnected => \&bot_reconnect,
                irc_error        => \&bot_reconnect,
                irc_socketerr    => \&bot_reconnect,
		message          => \&jabbotmsg
            },
            package_states => [
                'Jabbot::FrontEnd::IRC' => [qw(_start irc_join irc_public irc_msg irc_invite lag_o_meter)]
            ]
	);
    }

    $poe_kernel->run();
}

sub jabbotmsg {
    my ($kernel,$heap,$msg) = @_[KERNEL,HEAP,ARG0];
    my ($network,$channel) = @$msg{qw(network channel)};

# Notice:
# IKC-ClientLite has to use FreezeThaw as serializer instead of Storable.
# So that the scalar we get here are just bytes. Without utf8 flag turned on.
# Otherwise it turns encoding strings all mess!

# The $msg->{text} has utf8 flag off, but it's a valid utf8 sequence
    my $text = decode('utf8',$msg->{text});

    my $encoding = $self->hub->config->{"channel_encoding_${network}_${channel}"} || $self->hub->config->default_encoding || 'utf8';

    my $channel_text = encode($encoding,$text);

    $kernel->post($network, privmsg => "#$channel", $channel_text );

    say "[${network}/#$channel] on $text " . localtime(time);
    return 0;
}

sub irc_invite {
    my ($kernel,$channel, $heap) = @_[KERNEL,ARG1, HEAP];
    my $irc = $heap->{irc};
    $irc->yield(join => $channel);
    say "Bot invited to $channel";
}

sub _start {
    my ($kernel,$heap) = @_[KERNEL,HEAP];
    my $irc = $heap->{irc};
    my $alias = $irc->session_alias();
    my ($network) = $alias =~ /irc_frontend_(.+)/;
    say "Starting irc session, Connecting to $network";
    $kernel->call( IKC => publish => $alias => ['message'] );

    $heap->{connector} = POE::Component::IRC::Plugin::Connector->new();
    $irc->plugin_add('Connector' => $heap->{connector});
    $irc->plugin_add('AutoJoin', POE::Component::IRC::Plugin::AutoJoin->new(Channels => $self->hub->config->{irc}{$network}{channels}));

    $irc->yield(register => 'join');
    $irc->yield(register => 'all');
    $irc->yield(connect => {});

    $kernel->delay( 'lag_o_meter' => 60 );
}

sub bot_reconnect {
    my ($kernel,$heap) = @_[KERNEL,HEAP];
    say "reconnect: ".$_[ARG0];
    $kernel->delay(autoping=>300);
    $kernel->delay(connect=>60);
}

sub irc_msg {
    my ($kernel,$heap,$who,$where,$msg) = @_[KERNEL,HEAP,ARG0..$#_];
    my $irc = $heap->{irc};
    my $network = $heap->{network};
    my $encoding = "utf8";
    my $pubmsg  = decode($encoding,$msg);
    my $nick = ( split /!/, $who )[0];

    say "[$network/$who/$nick] $pubmsg";

    my $reply = $self->hub->process(
        $self->hub->message->new(
            text => $pubmsg,
            from => $nick,
            channel => '',
            to => $self->hub->config->nick
        )
    );

    my $reply_text = $reply->text;
    if(length($reply_text)) {
        $reply_text = encode($encoding,$reply_text);
        $irc->yield(privmsg => $nick => $reply_text);
    }
}

sub irc_public {
    my ($kernel,$heap,$who,$where,$msg) = @_[KERNEL,HEAP,ARG0..$#_];
    my $irc = $heap->{irc};
    my $network = $heap->{network};
    $heap->{seen_traffic} = 1;

    my $nick = ( split /!/, $who )[0];
    my $channel = lc($where->[0]);
    $channel =~ s{^\#}{};
    my $encoding = $self->hub->config->{"channel_encoding_${network}_${channel}"} || $self->hub->config->default_encoding || 'utf8';
    $channel = '#'.$channel;
    my $pubmsg  = decode($encoding,$msg);

    say "[$network/$channel encoding=\"$encoding\"] $pubmsg";

    my $to = sub {
       return '' if($_[0] =~ /^\s*http/i);
       if($_[0] =~ s/^([\d\w\|]+)\s*[:,]\s*//) { return $1; }
       return '';
    }->($pubmsg);

    my $reply = $self->hub->process(
        $self->hub->message->new(
            text => $pubmsg,
            from => $nick,
            channel => $channel,
            to => $to));

    my $reply_text = $reply->text;
    if ($reply_text && (($reply->must_say) ||  ($to eq $self->hub->config->nick)) ) {
        $reply_text = encode($encoding,"$nick: $reply_text");
        $irc->yield(privmsg => $channel, $reply_text);
    }
}

sub lag_o_meter {
    my ($kernel,$heap) = @_[KERNEL,HEAP];
    print 'Time: ' . time() . ' Lag: ' . $heap->{connector}->lag() . "\n";
    $kernel->delay( 'lag_o_meter' => 60 );
    return;
}

1;
