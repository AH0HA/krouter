#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use POSIX qw(strftime);


#getDate return date in string format 20161010
sub getDate{
my $date = strftime "%Y%m%d", localtime;
#print $date;
return $date;
}
#end getDate

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
#hash2print
#print out hash table in k<file_name> format
#
sub hash2print{
    (my $hashref,my $debug) = @_;
    my %HoH = %$hashref;

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

#
#hash2file2
#print out hash table in k<file_name> format
#
sub hash2file2{
    #(my %HoH,my $debug) = @_;
    (my $hashref,my $fh) = @_;
    my %HoH = %$hashref;
    #my %HoH = shift;
    #my $fh = shift;
    #my $debug = shift ||0;

    my $family;
    my $role;

    for $family ( keys %HoH ) {
        #print "$family\n";
        for $role ( keys %{ $HoH{$family} } ) {
             #if ($debug){
              #  print $fh "family:$family\n";
               # print $fh "role: $role\n";
             #}
             print $fh "$role=$HoH{$family}{$role}";

        }
        print $fh "\n";
    }

    close $fh;
}
#
#end hash2file2
#

sub dispatch{

        my $event= shift;
        my $debug = shift||0;
        my $mail_prog = shift || "mailx";
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
            print "$mail_prog\n";
        }

        my $email1_tag="email1";
        my $email1_cnt_tag="email1_cnt";
        my $email2_tag="email2";

        my $xemail1 = $h2{$event}{$email1_tag};
        my $xemail2 = $h2{$event}{$email2_tag};
        my $xemail1_cnt = $h2{$event}{$email1_cnt_tag};

        #initialize today_event_cnt is not happened today
        my $today_event_cnt = $m2{$today}{$event}||1;
        if ($today_event_cnt  == 1){
            $m2{$today}{$event} = 1;
        }

        if ($debug){
            print "$xemail1\n";
            print "$xemail2\n";
            print "$xemail1_cnt\n";
            print "$today_event_cnt\n";
        }

        my $mail1_cmd_str = $mail_prog." -s ".$event." ".$xemail1;
        my $mail2_cmd_str = $mail_prog." -s ".$event." ".$xemail2;

        if ($today_event_cnt + 1 >$xemail1_cnt){

            system "$mail2_cmd_str";

        }else{

            system "$mail1_cmd_str";

        }


        #hash2print(\%m2);
        #open my $rm3d_fh, '>', $memory_f or die "...$!";
        #hash2file2(\%m2,$rm3d_fh);
        hash2print(\%m2);





}#end dispatch



#my %h2=&file2hash("kconfig");
#my %m2=&file2hash("kmem");
#hash2print(%h2);
#hash2print(%m2);
#print &getDate();
#my $xcnt= &dispatch("event_c3_z2");
&dispatch("event_c3_z2",1,"echo");
#&dispatch("event_c3_z2",1);
#print $xcnt;






