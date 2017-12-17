use strict;
use warnings;

require 5.010_0;

use Log::Handler; #Logging service
use File::Basename; #seperates full filenames into their base parts
use Getopt::Long; #To get commandline options
use Config::Auto; #for reading in config files
use Time::SoFar qw( runtime runinterval ); #track how long it takes to do stuff

use LWP::UserAgent;
use base "HTML::Parser";
#use Geo::Coder::HostIP;


=head1 NAME

whereami.pl - return my lat/lon based on dns name

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This script is intended to provide an example/template to use

	./example.pl
		-c <config file>
			By default this is <filename>.config
		-v <max log level>
			Use the the list below:
				7   debug
				6   info
				5   notice
				4   warning, warn
				3   error, err  <--this is the default
				2   critical, crit
				1   alert
				0   emergency, emerg
=cut

my ($sincelast, $runtime); #vars used to monitor the runtime


#setup the log handler
my $log = Log::Handler->new();
my $logminlevel = "emergency";
my $logmaxlevel = "error";
#my $logmaxlevel = "debug";
$log->add(
	screen => {
		minlevel => $logminlevel,
		maxlevel => $logmaxlevel,
	}
);


#grab the commandline parameters
my $dnsname = "ws01.asyla.org";
GetOptions ('n=s' => \$dnsname, 'v=s' => \$logmaxlevel);
$log->debug("dnsname = $dnsname");


# go fetch geoloc info from maxmind
my $url = "http://www.maxmind.com/app/locate_my_ip";
my $searchstring = "Latitude/Longitude";
my $match = 0;

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(POST => $url); # Create a request
my $res = $ua->request($req); # Pass request to the user agent and get a response back

# Check the outcome of the response
if ($res->is_success) {
	my $p = HTML::Parser->new (
		api_version => 3,
		report_tags => ['tr'], #array of tags we will watch for
		start_h => [\&start, "self"],
	);
	$p->parse($res->content);	
	$p->eof;
} else {
	#print $res->status_line, "\n";  #this will print out the error messages
}



#this uses http://www.hostip.info/
#my $geo = new Geo::Coder::HostIP;
#my ($lat, $long) = $geo->FetchName('$dnsname');
#if (defined $lat && defined $long) {
#	print ("$lat, $long\n");
#} else {
#	$log->error("unknown location");
#}



$runtime = runtime(1);
$log->info("Total elapsed runtime: $runtime");


#########################################################################


sub start {
	my $self = shift;
	$self->handler(text => \&printloc, "dtext");
}

sub printloc {
	my $string = shift;
	$string =~ s/\R//g;
	if ($string =~ /\w/ && $match) { $match = 0; $string =~ s/\// /; print "$string"; }
	if ($string =~ /$searchstring/) { $match = 1; }
}

