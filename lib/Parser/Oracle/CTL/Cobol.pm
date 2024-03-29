package Parser::Oracle::CTL::Cobol;

use 5.10.0;
use strict;
use warnings;

our $VERSION = '0.03';
use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw/parser/;

sub parser ($) {
    my $ctl = shift;

    die "argumento is null" unless $ctl;

    my $struct = {};

    $ctl =~ s/[\r\n]+/\n/g;
    $ctl =~ s/^\-\-.+//g;
    if ( $ctl =~
/(INSERT|REPLACE|APPEND|TRUNCATE).*?INTO\s+TABLE\s+"?([\d\w_\.]+)"?.*?\((.+)\)/si
      )
    {
        my ( $rule, $table, $columns ) = ( uc $1, uc $2, uc $3 );
        $struct->{rule} = $rule;
        if ( $table =~ /(.+)\.(.+)/ ) {
            $struct->{table} = $2;
            $struct->{owner} = $1;
        }
        else {
            $struct->{table} = $table;
            $struct->{owner} = 'NULL';
        }
        $struct->{columns} = parser_columns($columns);
        return $struct;
    }
    elsif ( $ctl =~
/(INSERT|REPLACE|APPEND|TRUNCATE).*?INTO\s+([\w\d]+)\.TABLE\s+"?([\d\w_\.]+)"?.*?\((.+)\)/si
      )
    {
        my ( $rule, $owner, $table, $columns ) = ( uc $1, uc $2, uc $3, uc $4 );
        $struct->{rule}    = $rule;
        $struct->{table}   = $table;
        $struct->{owner}   = $owner;
        $struct->{columns} = parser_columns($columns);
        return $struct;
    }
    elsif ( $ctl =~ /INTO\s+TABLE\s+([\d\w_\.]+).*?\((.+)\)/si ) {
        my ( $rule, $table, $columns ) = ( 'INSERT', uc $1, uc $2 );
        $struct->{rule} = $rule;
        if ( $table =~ /(.+)\.(.+)/ ) {
            $struct->{table} = $2;
            $struct->{owner} = $1;
        }
        else {
            $struct->{table} = $table;
            $struct->{owner} = 'NULL';
        }
        $struct->{columns} = parser_columns($columns);
        return $struct;
    }
    else {
        die "{$ctl}";
    }
}

sub parser_columns {
    my $columns = clean_columns(shift);

    my $struct = {};
    my @items = split /,/s, $columns;
    foreach my $item (@items) {
        next unless $item =~ /\w+/;
        if ( $item =~ /([\w\d_]+)\s+position\s*?\(([\s\w\d:]+)\)\s*+(.*+)/i ) {
            my ( $column, $position, $rule ) = ( uc $1, uc _clean($2), $3 );
            $rule =~ s/,$//;
            $rule =~ s/^\s+|\s+$//g;
            $rule =~ s/#/,/g;
            $rule =~ s/^["'](.+)["']$/$1/g;
            $struct->{$column} = {
                position => $position,
                rule     => $rule
            };
        }
        elsif ( $item =~ /([\w\d_]+)\s+(\w+)\s+([^\s]+)/i ) {
            my ( $column, $rule1, $rule2 ) = ( uc $1, uc $2, uc $3 );
            $rule2 =~ s/,$//;
            $rule2 =~ s/^\s+|\s+$//g;
            $rule2 =~ s/#/,/g;
            $rule2 =~ s/^["'](.+)["']$/$1/g;
            $struct->{$column} = {
                position => 'NULL',
                rule     => "$rule1 $rule2"
            };

        }
        elsif ( $item =~ /([\w\d_]+)\s+(["\(\)\w:\d]+)/i ) {
            my ( $column, $rule ) = ( uc $1, $2 );
            $rule =~ s/,$//;
            $rule =~ s/^\s+|\s+$//g;
            $rule =~ s/#/,/g;
            $rule =~ s/^["'](.+)["']$/$1/g;
            $struct->{$column} = {
                position => 'NULL',
                rule     => $rule
            };
        }
        elsif ( $item =~ /([\w\d_]+)/ ) {
            $struct->{ uc $1 } = {
                position => 'NULL',
                rule     => 'NULL'
            };
        }
        else {
            die "{$columns}\n\n\n{$item}";
        }
    }
    return $struct;
}

sub clean_columns {
    my $string = shift;
    my @chars = split //, $string;
    foreach my $delimit ( ( [ q{'}, q{'} ], [ q{"}, q{"} ], [ q{(}, q{)} ] ) ) {
        my $match = 0;
        for ( my $i = 0 ; $i <= $#chars ; $i++ ) {
            if ( $chars[$i] eq $delimit->[0] ) {
                $match++;
            }
            if ( $match >= 1 ) {
                $chars[$i] = '#' if ord $chars[$i] == 44;
            }
            $match-- if $chars[$i] eq $delimit->[1];
        }
    }
    return join "", @chars;
}

sub _clean {
    my $s = shift;
    $s =~ s/\s+//g;
    return $s;
}

42;    # End of Parser::Oracle::CTL

__END__

=head1 NAME

Parser::Oracle::CTL - Parser for Oracle SQL Loader CTL for Cobol!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Return data structure from cobol SQL Loader CTL

	use Parser::Oracle::CTL;
	use Data::Dumper;
	...
	my $struct = parser $ctl_string;
	print Dumper $struct;


=head1 Oracle Default

L<http://docs.oracle.com/cd/B10500_01/server.920/a96652/ch05.htm>

=head2 Table-Specific Loading Method

When you are loading a table, you can use the INTO TABLE clause to specify a table-specific loading method (INSERT, APPEND, REPLACE, or TRUNCATE) that applies only to that table. That method overrides the global table-loading method. The global table-loading method is INSERT, by default, unless a different method was specified before any INTO TABLE clauses. The following sections discuss using these options to load data into empty and nonempty tables.

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 parser

give a hashref with parser structure, receive a string parameter.

=head1 AUTHOR

Daniel de Oliveira Mantovani, C<< <daniel.oliveira.mantovani at gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Daniel de Oliveira Mantovani.
