#!/usr/local/bin/perl
use strict;
use warnings;

use lib 'lib';
use Jabbot;
my @configs = qw(config.yaml -plugins plugins);

Jabbot->new->load_hub('config.yaml')->console->process(@ARGV);

