#!perl -T

use Test::More tests => 28;
use Parser::Oracle::CTL::Cobol;

use strict;
use warnings;

open my $fh, '<', 't/data/test2.CTL' or die $!;
my $ctl = join "", <$fh>;
close $fh;

my $struct = parser $ctl;

ok( ref $struct eq 'HASH', 'Structure' );
is( keys %{ $struct->{columns} }, 17, 'Column Number' );

# - Struct

my @columns =
  qw/CDPRO NUPRP CDAGNCONS INCNTAGRP NUAGNVENC INCMSSIT VLCNTOINT VLCNTOEXT INHVOCVEN INHVOMCOM CDSISCAD CDCNTBCOE INCNTTPOI INTXTALTC INTXTINCC INCNTCOMI DHSISCAD/;

foreach my $column (@columns) {
    is( ref $struct->{columns}->{$column}, 'HASH', "Testing column $column" );
}

# - Rule

is(
    $struct->{columns}->{VLCNTOINT}->{rule},
    q{"REPLACE(:VLCNTOINT , ',' , '.')"    },
    'Rule VLCNTOINT'
);

is( $struct->{columns}->{INCNTAGRP}->{rule}, '', 'Rule INCNTAGRP' );
is( $struct->{columns}->{INCMSSIT}->{rule},
    'NULLIF(028:029)=BLANKS              ', 'Rule INCMSSIT' );
is(
    $struct->{columns}->{VLCNTOEXT}->{rule},
    q{"REPLACE(:VLCNTOEXT , ',' , '.')"    },
    'Rule VLCNTOEXT'
);
is( $struct->{columns}->{CDAGNCONS}->{rule},
    '"TO_NUMBER(:CDAGNCONS, 999999999   )"', 'CDAGNCONS' );

# - Position

is( $struct->{columns}->{CDPRO}->{position}, '001:004', 'CDPRO' );
is( $struct->{columns}->{CDAGNCONS}->{position},
    '012:020', 'Position CDAGNCONS' );
is( $struct->{columns}->{INCNTAGRP}->{position},
    '021:022', 'Position INCNTAGRP' );
is( $struct->{columns}->{DHSISCAD}->{position}, '088:106', 'DHSISCAD' );
