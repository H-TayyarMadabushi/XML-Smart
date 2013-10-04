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


subtest 'to_scalar_actual_data' => sub {

    my @xml = <DATA>            ;
    my $xml = join( '', @xml )  ;
    
    my $XML = new XML::Smart( $xml );
    
    my @result = ();
    my %expected_results = ( 
	'StatusWorkbook'  =>  'StatusWorkbook = S2_RBE_Current.xlsm'                                      ,
	'PlanDatabase'    =>  'PlanDatabase = H:\A350 Data\SES Verification Traceability\SESVerTrace.mdb' ,
	'Campaign'        =>  'Campaign = S2.2RBE;'                                                       ,
	);

    foreach my $key ('StatusWorkbook', 'PlanDatabase', 'Campaign' ) {
	my $value = $XML->{StatusUpdate}{$key}('$');
	cmp_ok( "$key = $value", 'eq', $expected_results{ $key } ) ;
	die "Missing key: $key in configuration file.\n" if ! $value;
	push @result, $value
    }

    is_deeply( \@result, [
		   "S2_RBE_Current.xlsm",
		   "H:\\A350 Data\\SES Verification Traceability\\SESVerTrace.mdb",
		   "S2.2RBE;",
	       ], 'Extrected Scalar Values' );
    
    done_testing() ;

};

done_testing() ;

__DATA__
<StatusUpdate>
	<DimensionsCCWB>A350_CCWB_20</DimensionsCCWB>
	<DimensionsCCWB>A350_CCWB_32</DimensionsCCWB>
	<StatusWorkbook>S2_RBE_Current.xlsm</StatusWorkbook>
	<PlanDatabase>H:\A350 Data\SES Verification Traceability\SESVerTrace.mdb</PlanDatabase>
	<Campaign>S2.2RBE;</Campaign>
</StatusUpdate>

