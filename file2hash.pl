#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use POSIX qw(strftime);


#getDate return date in string format 20161010
sub getDate{
my %date_rec;
my $date_short = strftime "%Y%m%d", localtime;
my $date_long = strftime "%Y%m%d%H%M%S", localtime;
#print $date;
$date_rec{'long'} = $date_long;
$date_rec{'short'} = $date_short;
return %date_rec;
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



    my $family;
    my $role;

    my $key_tag=': ';
    for $family (sort keys %HoH ) {
        print "$family$key_tag";
        for $role ( sort keys %{ $HoH{$family} } ) {
             if ($debug){
               print "family:$family\n";
                print "role: $role\n";
             }
             print "$role=$HoH{$family}{$role} ";

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
        my $mail_prog = shift || "mailx";
        my $config_f = shift || "kconfig";
        my $memory_f = shift || "kmem";

        my $email1_tag="email1";
        my $email1_cnt_tag="email1_cnt";
        my $email2_tag="email2";
        my $email3_tag="email3";
        my $email2_cnt_tag="email2_cnt";

        my %h2=&file2hash($config_f);
        my %m2=file2hash($memory_f);

        my %today=&getDate();
        my $today_idx = $today{'short'};
        my $today_ext = $today{'long'};

        if ($debug){
            print "$today_idx\n";
            print "$today_ext\n";
            print "$event\n";
            print "$config_f\n";
            print "$memory_f\n";
            print "$mail_prog\n";
        }




        my $xemail1 = $h2{$event}{$email1_tag};
        my $xemail2 = $h2{$event}{$email2_tag};
        my $xemail1_cnt = $h2{$event}{$email1_cnt_tag};
        my $xemail3 = $h2{$event}{$email3_tag};
        my $xemail2_cnt = $h2{$event}{$email2_cnt_tag};

        #initialize today_event_cnt is not happened today
        if (exists $m2{$event}{$today_idx}) {
            $m2{$event}{$today_idx} = $m2{$event}{$today_idx} +1;
            $m2{$event}{$today_ext} = 1;
        }else{
             $m2{$event}{$today_idx} = 1;
             $m2{$event}{$today_ext} = 1;
        }



        if ($debug){
            print "$xemail1\n";
            print "$xemail2\n";
            print "$xemail1_cnt\n";
        }

        my $mail1_cmd_str = $mail_prog." -s ".$event." ".$xemail1;
        my $mail2_cmd_str = $mail_prog." -s ".$event." ".$xemail2;
        my $mail3_cmd_str = $mail_prog." -s ".$event." ".$xemail3;


        if ($m2{$event}{$today_idx} >$xemail2_cnt){

            system "$mail3_cmd_str";

        }elsif($m2{$event}{$today_idx} >$xemail1_cnt){

            system "$mail2_cmd_str";

        }else{

           system "$mail1_cmd_str";

        }

        # open filehandle for memory_file
        # might need mutex protection ??
        #
        open (my $mymem, '>', $memory_f);

        # select new filehandle
        select $mymem;
        hash2print(\%m2);
        close $mymem;
        #hash2priint(\%m2);
        #open my $rm3d_fh, '>', $memory_f or die "...$!";
        #hash2file2(\%m2,$rm3d_fh);





}#end dispatch



#my %h2=&file2hash("kconfig");
#my %m2=&file2hash("kmem");
#hash2print(\%h2);
#hash2print(\%m2);
#print &getDate();
#my $xcnt= &dispatch("event_c3_z2");
&dispatch("event_c3_z2",0,"echo");
#&dispatch("event_c3_z2",1);
#print $xcnt;






