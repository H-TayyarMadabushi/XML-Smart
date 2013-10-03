#!perl -T
use 5.006                   ;
use strict                  ;
use warnings FATAL => 'all' ;
use Test::More              ;

use XML::Smart              ;  


# Bug id - 89228




subtest 'Convert_to_Scalar' => sub {

    my $XML   = XML::Smart->new();
    $XML->{StatusUpdate}{19} = 'A350_CCWB_19';
    $XML->{StatusUpdate}{20} = 'A350_CCWB_20';

    my $key   = 20                              ;
    my $value = $XML->{StatusUpdate}{$key}('$') ;

    my $tmp = ref $value ;
    cmp_ok( $tmp, 'eq', '', 'Scalar Test' );

    $tmp = ref $XML ;
    cmp_ok( $tmp, 'eq', 'XML::Smart', 'Control Test' );

    done_testing() ;

};

done_testing() ;
