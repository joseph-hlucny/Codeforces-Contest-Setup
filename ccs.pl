#!/user/bin/perl
use strict;
use warnings;
use LWP;
use diagnostics;
use JSON;
use 5.30.2;
use Getopt::Long qw(GetOptions);

my $language_option = 'cpp';
GetOptions(
    'language|l=s' => \$language_option,
) or die "Usage: $0 --language [LANGUAGE]\n\nSee --help for more details"; #TODO: Make a help option


my $num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\n\nUSAGE:  perl ccs.pl [CONTEST_ID] --language [LANGUAGE]\n\n"
}


else {
    # Setting up URL
    print "Creating files for contest with id: ", $ARGV[0], "...\n";
    my $contest_url = "https://codeforces.com/api/contest.standings?contestId=$ARGV[0]";

    my $browser = LWP::UserAgent->new;
    my $response = $browser->get($contest_url);
    die "Can't get $contest_url -- ", $response->status_line
        unless $response->is_success;
    # decodes response and converts into a pointer to a perl hash data structure
    my $message = $response->decoded_content;
    my $contest_data = from_json($message);
    
    # Determines which programming language should be set up
    # Clones base contest folder from Codeforces-Contest git repo
    my $contest_id = $contest_data->{'result'}->{'contest'}->{'id'};
    if ($language_option) {
        if ($language_option eq 'cpp') {
            `git clone --single-branch --branch cpp https://github.com/joseph-hlucny/Codeforces-Contest.git contest\\Codeforces-Contest`;
        }
        if ($language_option eq 'pl') {
            `git clone --single-branch --branch pl https://github.com/joseph-hlucny/Codeforces-Contest.git contest\\Codeforces-Contest`;
        }
    }
    
    `ren contest\\Codeforces-Contest $contest_id`;

    # creates a problem subfolder for each problem
    my $problems = $contest_data->{'result'}->{'problems'};
    foreach my $element (@$problems) {
        print 'Creating problem ', $element->{'index'}, "...\n";
        `mkdir contest\\$contest_id\\$element->{'index'}`;
        `robocopy -s contest\\$contest_id\\sample_problem contest\\$contest_id\\$element->{'index'}`;
        `ren contest\\$contest_id\\$element->{'index'}\\sample_problem.$language_option $element->{'index'}.$language_option`;
    }
    `rmdir /q /s contest\\$contest_id\\sample_problem`;
    print "Processing complete.\n\nglhf...\n\n";
}