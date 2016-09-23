#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#sub read_config {

#my $xfile = $ARGV[0] or die "Need to get config file on the command line\n";
#my $xdebug = $ARGV[3];
#my $xmsg = $ARGV[1];

#my $xmemory = $ARGV[2];

#my $file = 'kconfig';
#GetOptions ('config:s' => \$file);

#my $debug=0;
#GetOptions ('debug:i' => \$debug);

#sub read_file {
#    my %args=@_;
#    my %defaults=( my $file=>'kconfig',  my $mem=>'kmem', my $debug=>0);
#    foreach (keys %defaults) {
        #defined ($args{$_})  || {$args{$_}= $defaults{$_}} ;
#        defined($args{$_}) || ($args{$_}=$default{$_});
#        print $_ ," - ",$args {$_},"\n";
#    }
#}

my ($file,$mem,$debug) = @_;
$say ||= "kconfig";
$to ||= "kmem";
$debug||=1


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

return %HoH;

}

#read_config(config2);
&readFile (debug=>1);




