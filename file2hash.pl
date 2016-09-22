#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

sub file2hash {
    my ($file) = @_;

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

    return %HoH;

}

sub hash2print{
    my (%HoH) = @_;

my $family;
my $role;

#if ($debug) {
#to_do make a subroutine and add debug flag
    for $family ( keys %HoH ) {
        print "$family: ";
        for $role ( keys %{ $HoH{$family} } ) {
             print "$role=$HoH{$family}{$role} ";
        }
        print "\n";
    }
}

my %h2=&file2hash("kconfig");
&hash2print(%h2);