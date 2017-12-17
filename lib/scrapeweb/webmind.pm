package scrapeweb::webmind;

use warnings;
use strict;

require 5.010_0;

use Log::Handler;
use base "HTML::Parser";

=head1 NAME

some::example - example perl module

=head1 VERSION

Version 0.01
	this stuff most entirely came from http://perldoc.perl.org/perltoot.html

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This is just an example/template module to use 

use some::example;

my $foo = some::example->new();

$foo->log->add(
	screen => {
		maxlevel => "debug",
		minlevel => "warning",
	}
);
$foo->name("Jim");
$foo->age(10);
$foo->peers("Jake", "Joe", "Jane");

print "name = ", $foo->name, "\n";
print "age = ", $foo->{AGE}, "\n";
print "peers = ", @{$foo->{PEERS}}, "\n";

print $foo->exclaim, "\n";
print "happy_birthday = ", $foo->happy_birthday, "\n";

=head1 EXPORT

A list of functions that can be exported.  You can delete this section if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=cut

my $searchstring = "Latitude/Longitude";
my $match = 0;


=head2 new

Calls to/from this module should go through this function

=cut

sub new {
	my $class = shift;
	my $self = {};

	$self->{PARSER} = HTML::Parser->new (
		api_version => 3,
		report_tags => ['tr'], #array of tags we will watch for
		start_h => [\&start, "self"],
	);

	$self->{LOG} = Log::Handler->new(); #this handles the logging for the module
	bless ($self, $class);
	return $self;
}


sub start {
	my $self = shift;
	$self->handler(text => \&printloc, "dtext");
}


=head2 printloc

just print whatever is sent to me

=cut

sub printloc {
	my $string = shift;
	$string =~ s/\R//g;
	if ($string =~ /\w/ && $match) { $match = 0; $string =~ s/\// /; print "$string"; }
	if ($string =~ /$searchstring/) { $match = 1; }
}


=head2 printtext

just print whatever is sent to me

=cut

sub printtext {
	print shift;
}


=head2 parser

=cut

sub parser {
	my $self = shift;
	return $self->{PARSER};
}


=head2 log

Just used for passing stuff off onto Log::Handler

$self->log->warning("message");

=cut

sub log {
	my $self = shift;
	return $self->{LOG};
}


=head1 AUTHOR

Stephen Hepner, C<< <shepner at asyla.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-project at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=project>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc some::example


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=project>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/project>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/project>

=item * Search CPAN

L<http://search.cpan.org/dist/project/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Stephen Hepner.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of project
