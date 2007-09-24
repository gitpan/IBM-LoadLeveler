# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

use Test::Simple tests => 1 ;
use IBM::LoadLeveler;

ok( defined ll_version(), "ll_version returns a value" );
