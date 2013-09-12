use strict                  ;
use warnings FATAL => 'all' ;

use Test::More              ;

use ExtUtils::MakeMaker     ;

use XML::Smart              ;

subtest 'URL Tests' => sub {


    if( !$ENV{ URL_TESTS_FOR_SPECIAL_CHAR } ) { 
	plan skip_all => 'Skipping URL test, Enable by setting ENV variable URL_TESTS_FOR_SPECIAL_CHAR' ;
	done_testing() ;
    }

    my $url = 'http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=Frédéric%20Dard&srprop=sectiontitle&sroffset=0&srlimit=50&format=xml' ;
	    
    diag( "\nGetting URL... " ) ;
    
    my $XML = XML::Smart->new( $url , 'XML::Smart::Parser') ;
    
    $XML->save( 'tmp' );
    
    my $file_XML = XML::Smart->new( 'tmp' , 'XML::Smart::Parser') ;
    
    require Data::Dump          ;
    Data::Dump::dd( $file_XML ) ;

    ok( $file_XML ) ;


    done_testing() ;
    
} ;

done_testing() ;
