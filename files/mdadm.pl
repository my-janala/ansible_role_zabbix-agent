#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
use JSON;

# declare the perl command line flags/options we want to allow
my %options=();
getopts("Ds:", \%options);

if ($options{D}) {
    my $arrays_found = undef;
    open(my $fh, '-|', 'cat /proc/mdstat') or die $!;
    while (my $line = <$fh>) {
        if ($line =~ /^(md\S*)/) {
            if ($arrays_found) {
                push(@{$arrays_found->{'data'}},{'{#MD_DEVICE}' => ('/dev/' . $1)});
            } else {
                $arrays_found->{'data'}->[0] =  {'{#MD_DEVICE}' => ('/dev/' . $1)};
            }
        }
    }
    print encode_json($arrays_found) if ($arrays_found);
} elsif ($options{s}) {
    #Will be checking status of a given array
    open(my $fh, '-|', 'mdadm --detail ' . $options{s}) or die $!;
    while (my $line = <$fh> ) {
        if ($line =~ /State\s*:\s*(\S.*)$/) {
            print $1;
            last;
        }
    }
}
