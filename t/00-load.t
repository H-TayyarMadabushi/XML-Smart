#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'XML::Smart' ) || print "Bail out!\n";
}

diag( "Testing XML::Smart $XML::Smart::VERSION, Perl $], $^X" );
