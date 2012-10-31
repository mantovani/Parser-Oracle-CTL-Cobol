use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Parser::Oracle::CTL::Cobol',
    AUTHOR =>
      q{Daniel de Oliveira Mantovani <daniel.oliveira.mantovani@gmail.com>},
    VERSION_FROM  => 'lib/Parser/Oracle/CTL/Cobol.pm',
    ABSTRACT_FROM => 'lib/Parser/Oracle/CTL/Cobol.pm',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ( 'LICENSE' => 'perl' )
        : () ),
    PL_FILES  => {},
    PREREQ_PM => { 'Test::More' => 0, },
    dist      => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Parser-Oracle-CTL-Cobol-*' },
);
