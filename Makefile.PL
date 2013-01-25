###############
# MAKEFILE.PL #
###############

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'XML::Smart' ,
    'VERSION_FROM'	=> 'lib/XML/Smart.pm' ,
    'PREREQ_PM'		=> {'Object::MultiType'  => 0.03} ,
    ($] >= 5.005 ?
      ( ABSTRACT_FROM => 'lib/XML/Smart.pm',
        AUTHOR        => 'Graciliano M. P. <gm@virtuasites.com.br>'
       ) : ()
     ),
);

1;

