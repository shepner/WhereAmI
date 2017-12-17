use strict;
use warnings;

require 5.010_0;

use Log::Handler; #Logging service
use File::Basename; #seperates full filenames into their base parts
use Getopt::Long; #To get commandline options
use Config::Auto; #for reading in config files
use Time::SoFar qw( runtime runinterval ); #track how long it takes to do stuff

#use Geo::Coder::HostIP;

use lib './lib'; #only needed because the modules arent properaly installed
use scrapeweb::webmind;


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

#lets figure out what and where we are
#my($basename, $workingdir, $suffix) = fileparse($0, ".pl");
#$log->debug("basename=$basename, workingdir=$workingdir, suffix=$suffix");
#my $basename = basename($0,".pl");
#$log->debug("basename=$basename");

#grab the commandline parameters
#my $configfile = "$workingdir$basename.cfg";
#my $configfile = "$basename.config";
my $dnsname = "ws01.asyla.org";
#GetOptions ('c=s' => \$configfile, 'v=s' => \$logmaxlevel);
GetOptions ('n=s' => \$dnsname, 'v=s' => \$logmaxlevel);
#$log->debug("configfile=$configfile");
$log->debug("dnsname = $dnsname");

#load in the config file
#do "$configfile";  #load the file now
#use vars qw/%copyfilecfg/;  #these are the global vars to use from the config file
#my $config = Config::Auto::parse($configfile);
#foreach my $var (sort(keys(%$config))) {
#	$log->debug("$configfile:  $var=$$config{$var}");
#}


my $url = "http://www.maxmind.com/app/locate_my_ip";
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
#$ua->agent("MyApp/0.1 ");

# Create a request
my $req = HTTP::Request->new(POST => $url);
#$req->content_type('application/x-www-form-urlencoded');
#$req->content('query=libwww-perl&mode=dist');

# Pass request to the user agent and get a response back
my $res = $ua->request($req);

# Check the outcome of the response
if ($res->is_success) {
	#print $res->content; #this will print out the returned page
	my $p = scrapeweb::webmind->new();
	$p->parser->parse($res->content);
	#$p->parser->parse_file("./example/webmind.txt");
	
	$p->parser->eof;
} else {
	print $res->status_line, "\n";  #this will print out the error messages
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
