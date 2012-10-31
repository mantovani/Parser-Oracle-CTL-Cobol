#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Parser::Oracle::CTL::Cobol' ) || print "Bail out!\n";
}

diag( "Testing Parser::Oracle::CTL::Cobol $Parser::Oracle::CTL::Cobol::VERSION, Perl $], $^X" );
