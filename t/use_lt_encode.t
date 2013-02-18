use strict                ;
use warnings              ;

use Test::More            ;

use XML::Smart            ;

use Data::Dump qw( dump ) ;
BEGIN { 
    print STDERR "amp_fail.t contains debug code\n" ;
}



subtest 'use_lt_clean Test' => sub {
    
    my $xml_input = '
<sample>
<begin>
You must be < 18.
</begin>
<end>
<![CDATA[bla bla bla <tag> bla bla]]>
</end>
<other>
blah < blah ()
</other>
</sample>
';
    
    my $xml_obj = new XML::Smart( 
	$xml_input, 
	'XML::Smart::Parser' ,
	use_lt_clean => 1 
	) ;
    
    my $data = $xml_obj->data(
	'decode'    => 1 ,
	'noheader'  => 1 ,
	) ;
    
    $data =~ s/\n//gs;
    $data =~ s/\s+/ /gs;
    $data =~ s/>\s+</></g;
    
    $xml_input =~ s/\n//gs;
    $xml_input =~ s/\s+/ /gs;
    $xml_input =~ s/>\s+<//g;
    
    
    cmp_ok( $data, 'eq', $xml_input ) ;
    
    done_testing() ;

} ;



subtest 'use_lt_clean Test - Maintain Space' => sub {
    
    my $xml_input = '
<sample>
 <begin>
You must be < 18.
</begin>
<end> <rand> as<df </rand>
<![CDATA[bla bla bla <tag> bla bla]]>
</end>
<other>
blah  blah (<)
</other>
</sample>
';
    
    my $xml_obj = new XML::Smart( 
	$xml_input, 
	'XML::Smart::Parser' ,
	use_lt_clean => 1 
	) ;
    
    my $data = $xml_obj->data(
	'decode'    => 1 ,
	'noheader'  => 1 ,
 	) ;
    
    $data =~ s/\n//gs;
    $data =~ s/\s+/ /gs;
    $data =~ s/>\s+</></g;
    
    $xml_input =~ s/\n//gs;
    $xml_input =~ s/\s+/ /gs;
    $xml_input =~ s/>\s+</></g;
    
    
    cmp_ok( $data, 'eq', $xml_input ) ;
    
    done_testing() ;

} ;

subtest 'use_lt_clean Test - Multiple lt' => sub {
    
    my $xml_input = '
<sample>
 <begin>
You must be < 18.
</begin>
<end> <rand> as<<df </rand>
<![CDATA[bla bla bla <tag> bla bla]]>
</end>
<other>
blah < blah ()
</other>
</sample>
';
    
    my $xml_obj = new XML::Smart( 
	$xml_input, 
	'XML::Smart::Parser' ,
	use_lt_clean => 1 
	) ;
    
    my $data = $xml_obj->data(
	'decode'    => 1 ,
	'noheader'  => 1 ,
 	) ;
    
    $data =~ s/\n//gs;
    $data =~ s/\s+/ /gs;
    $data =~ s/>\s+</></g;
    
    $xml_input =~ s/\n//gs;
    $xml_input =~ s/\s+/ /gs;
    $xml_input =~ s/>\s+</></g;
    
    
    cmp_ok( $data, 'eq', $xml_input ) ;
    
    done_testing() ;

} ;

done_testing() ;