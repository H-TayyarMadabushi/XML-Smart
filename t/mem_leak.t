
use strict                  ;
use warnings FATAL => 'all' ;

use Test::More                    ;

use ExtUtils::MakeMaker     ;

use XML::Smart              ;


my $DATA = q`<?xml version="1.0" encoding="iso-8859-1"?>
<hosts>
    <server os="linux" type="redhat" version="8.0">
      <address>192.168.0.1</address>
      <address>192.168.0.2</address>
    </server>
    <server os="linux" type="suse" version="7.0">
      <address>192.168.1.10</address>
      <address>192.168.1.20</address>
    </server>
    <server address="192.168.2.100" os="linux" type="conectiva" version="9.0"/>
    <server address="192.168.3.30" os="bsd" type="freebsd" version="9.0"/>
</hosts>
`;
#########################
subtest 'Mem Leak' => sub {
    plan skip_all => 'Mem Check in progress ... ' ;
    eval(q`use XML::XPath`) ;
    if ( !$@ ) {
	my $XML = XML::Smart->new($DATA , 'XML::Smart::Parser') ;
	$$XML->{ DEV_DEBUG } = 1 ;
	
	my $xp1 = $XML->XPath ;
	my $xp2 = $XML->XPath ;
	ok($xp1,$xp2) ;
	
	$xp1 = $XML->XPath ;
	$XML->{hosts}{tmp} = 123 ;
	$xp2 = $XML->XPath ;
    }
    
    ok( 1 );
};

done_testing() ; 
#########################

1 ;



