#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#sub read_config {

my $file = $ARGV[0] or die "Need to get config file on the command line\n";
my $debug = $ARGV[1];

#my $file = 'kconfig';
#GetOptions ('config:s' => \$file);

#my $debug=0;
#GetOptions ('debug:i' => \$debug);



open(my $data, '<', $file) or die "Could not open '$file' $!\n";

my %HoH;
my $key;
my $value;
my $who;
my $rec;
my $field;

#while ( my $line = <$data>) {
while ( <$data>) {
    #print $line;
    next unless (s/^(.*?):\s*//);
    $who = $1;
    #print $who;
    $rec = {};
    $HoH{$who} = $rec;
    for $field ( split ) {
        ($key, $value) = split /=/, $field;
        $rec->{$key} = $value;
    }
}

my $family;
my $role;

if ($debug) {
#to_do make a subroutine and add debug flag
    for $family ( keys %HoH ) {
        print "$family: ";
        for $role ( keys %{ $HoH{$family} } ) {
             print "$role=$HoH{$family}{$role} ";
        }
        print "\n";
    }
}

#return %HoH;

#}

#read_config(config2);





