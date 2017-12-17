#!/usr/bin/perl

# This program will print out the title of an HTML document.

use strict;
use HTML::Parser ();

sub title_handler
{
    my $self = shift;
    $self->handler(text => sub { print @_ }, "dtext");
    $self->handler(end  => "eof", "self");
}

my $p = HTML::Parser->new(api_version => 3,
			  start_h => [\&title_handler, "self"],
			  report_tags => ['title'],
			 );
$p->parse_file("./asyla.txt" || die) || die $!;
print "\n";
