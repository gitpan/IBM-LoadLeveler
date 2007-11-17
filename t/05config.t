# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

use Test::Simple tests => 2 ;
use IBM::LoadLeveler;

my $read=ll_read_config();

ok( $read == API_OK, "ll_read_config - Config Read OK" );

my $changed=ll_config_changed();

ok( $changed == 0, "ll_config_changed - Config Not Changed" );