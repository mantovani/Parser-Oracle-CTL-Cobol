#!perl -T

use Test::More tests => 21;
use Parser::Oracle::CTL::Cobol;

open my $fh_1, '<', 't/data/test3.CTL' or die $!;
my $ctl1 = join "", <$fh_1>;
close $fh_1;

my $struct_1 = parser $ctl1;

ok( ref $struct_1 eq 'HASH', 'Structure' );
is( keys %{ $struct_1->{columns} }, 11, 'Column Number' );

# - Struct

my @columns =
  qw/NUM_CPF TIP_PESSOA NUM_SEQUENCIAL_EMAIL COD_RETORNO_EFETIVIDADE_EMAIL TXT_ENDERECO_EMAIL NUM_CLASSIFICACAO_SOBREV NUM_MES_RETORNO_EFETIVIDADE DAT_REFERENCIA_DADO COD_STATUS_ENRQC_EMAIL TIP_LOCALIZACAO COD_TITULARIDADE_CPF/;

foreach my $column (@columns) {
    is( ref $struct_1->{columns}->{$column}, 'HASH', "Testing column $column" );
}

# - Rule

is(
    $struct_1->{columns}->{DAT_REFERENCIA_DADO}->{rule},
    'DATE(8) "YYYYMMDD"',
    'Rule DAT_REFERENCIA_DADO'
);

is( $struct_1->{columns}->{TIP_PESSOA}->{rule}, '', 'Rule TIP_PESSOA' );
is( $struct_1->{columns}->{COD_STATUS_ENRQC_EMAIL}->{rule},
    '', 'Rule COD_STATUS_ENRQC_EMAIL' );
is( $struct_1->{columns}->{NUM_MES_RETORNO_EFETIVIDADE}->{rule},
    '', 'Rule NUM_MES_RETORNO_EFETIVIDADE' );

# - Position

is( $struct_1->{columns}->{TIP_PESSOA}->{position},
    '132:132', 'Postion TIP_PESSOA' );
is( $struct_1->{columns}->{COD_TITULARIDADE_CPF}->{position},
    '118:118', 'Position COD_TITULARIDADE_CPF' );
is( $struct_1->{columns}->{NUM_CPF}->{position}, '1:12', 'Position NUM_CPF' );
is( $struct_1->{columns}->{DAT_REFERENCIA_DADO}->{position},
    '123:130', 'Position DAT_REFERENCIA_DADO' );
