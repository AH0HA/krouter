#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use POSIX qw(strftime);


#
#file2hash : read the file in k<file_name> e.g.=kconfig &  kmem  into hash table
#

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
#
#end file2hash
#


#
#print out hash table in k<file_name> format
#
sub hash2print{
    (my %HoH,my $debug) = @_;
    #my ($debug)=@_||0;
    #my %HoH = shift;
    #my $debug = shift || 0;

    my $family;
    my $role;

    for $family ( keys %HoH ) {
        #print "$family\n";
        for $role ( keys %{ $HoH{$family} } ) {
             if ($debug){
                print "family:$family\n";
                print "role: $role\n";
             }
             print "$role=$HoH{$family}{$role}";

        }
        print "\n";
    }
}
#
#end hash2print
#

sub dispatch{

        my $event= shift;
        my $debug = shift||0;
        my $config_f = shift || "kconfig";
        my $memory_f = shift || "kmem";

        my %h2=&file2hash($config_f);
        my %m2=file2hash($memory_f);

        my $today=&getDate();

        if ($debug){
            print "$today\n";
            print "$event\n";
            print "$config_f\n";
            print "$memory_f\n";
        }

        my $ctag1="email1";
        my $ctag2="email1_cnt";
        my $ctag3="email2";

        if ($debug){
            print "$h2{$event}{$ctag1}\n";
            print "$h2{$event}{$ctag3}\n";
            print "$h2{$event}{$ctag2}\n";
            print "$m2{$today}{$event}\n";
        }

        #my $inc_cnt = $m2{$today}{$inc} || -999999999;
        #print "$inc_cnt\n";

        #my %config = shift;
        #my %mem = shift;
        #my $event = shift;
        #print $m2{$inc}{$today};
}

sub getDate{
my $date = strftime "%Y%m%d", localtime;
#print $date;
return $date;
}

my %h2=&file2hash("kconfig");
my %m2=&file2hash("kmem");
#hash2print(%h2);
#hash2print(%m2);
#print &getDate();
#my $xcnt= &dispatch("event_c3_z2");
&dispatch("event_c3_z2");
#print $xcnt;






