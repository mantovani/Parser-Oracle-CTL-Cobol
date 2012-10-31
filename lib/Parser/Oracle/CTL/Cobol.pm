package Parser::Oracle::CTL::Cobol;

use 5.10.0;
use strict;
use warnings;

BEGIN {
    our $VERSION = '0.01';
    use Exporter;
    our @ISA    = qw(Exporter);
    our @EXPORT = qw/parser/;
}

sub parser ($) {
    my $ctl = shift;

    die "argumento is null" unless $ctl;

    my $struct = {};

    $ctl =~ s/[\r\n]+/\n/g;
    if ( $ctl =~
/(INSERT|REPLACE|APPEND|TRUNCATE).*?INTO\s+TABLE\s+([\d\w_\.]+).*?\((.+)\)/si
      )
    {
        my ( $rule, $table, $coluns ) = ( uc $1, uc $2, uc $3 );
        $struct->{rule} = $rule;
        if ( $table =~ /(.+)\.(.+)/ ) {
            $struct->{table} = $2;
            $struct->{owner} = $1;
        }
        else {
            $struct->{table}   = $table;
            $struct->{columns} = parser_coluns($coluns);
        }
    }
    return $struct;
}

sub parser_coluns {
    my $coluns = shift;
    $coluns =~ s/\((.*?),(.*?)\)/$1#$2/g;
    my $struct = {};
    while (
        $coluns =~ s/([\w\d_]+)\s+position\s*?\(([\s\w\d:]+)\)\s*+(.*+),*+//i )
    {
        my ( $column, $position, $rule ) = ( uc $1, uc _clean($2), $3 );
        $rule =~ s/,$//;
        $struct->{$column} = {
            position => $position,
            rule     => $rule
        };
    }
    return $struct;
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

=head1 BUGS

Please report any bugs or feature requests to C<bug-parser-oracle-ctl at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Parser-Oracle-CTL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Parser::Oracle::CTL


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Parser-Oracle-CTL>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Parser-Oracle-CTL>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Parser-Oracle-CTL>

=item * Search CPAN

L<http://search.cpan.org/dist/Parser-Oracle-CTL/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Daniel de Oliveira Mantovani.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


## Please see file perltidy.ERR
