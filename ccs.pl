#!/user/bin/perl
use strict;
use warnings;
use LWP;
use diagnostics;
use JSON;
use 5.30.2;

my $num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\n\nUSAGE:  perl ccs.pl [CONTEST_ID]\n\n"
}
else {
    # Setting up URL
    print "Creating files for contest with id: ", $ARGV[0], "...\n";
    my $contest_url = "https://codeforces.com/api/contest.standings?contestId=$ARGV[0]";

    my $browser = LWP::UserAgent->new;
    my $response = $browser->get($contest_url);
    die "Can't get $contest_url -- ", $response->status_line
        unless $response->is_success;
    print "success\n";
    # decodes response and converts into a pointer to a perl hash data structure
    my $message = $response->decoded_content;
    my $contest_data = from_json($message);
    
    `git clone --single-branch --branch C++-Language https://github.com/joseph-hlucny/Codeforces-Contest.git`;

    my $problems = $contest_data->{'result'}->{'problems'};

    foreach my $element (@$problems) {
        print $element->{'index'}, "\n";
    }
	
}
