#!perl -T
use 5.006                   ;
use strict                  ;
use warnings FATAL => 'all' ;
use Test::More              ;

use XML::Smart              ;  


subtest 'Raw Binary Data' => sub {

    my $bin_data_string = '€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßàáâãäåæçèéêëìíîïğñòóôõö÷øùúûüışÿ' ;
    my @bin_data = split( //, $bin_data_string ) ;
    foreach my $bin_elem ( @bin_data ) { 
	cmp_ok( XML::Smart::_data_type( $bin_elem ), '==', 1, 'RawBinData' );
    }

    done_testing() ;
};

done_testing() ;

