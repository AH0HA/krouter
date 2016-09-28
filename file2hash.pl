#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use POSIX qw(strftime);
use Fcntl qw(:flock);


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
#my $MAX_FILE_TRY = 20;
my $sleep_time = 2;
my $XLOCKFILE ="kmem.lock";

sub file2hash {
    my ($file) = @_;
    my $xfh;



    for (;;)
    {
    # See if lock Status has changed.
         my $lock_status=check_lock_exists();

           if ($lock_status == 0)
           {
               print "-----Lock  exist,sleeping for $sleep_time------\n";
              # lock Status Changed.
              # Sleep for 10 to Check the Lock status again
               sleep($sleep_time);
           }
           else
           {
              $xfh = get_lock();
              last;
           }
    }#end for

#http://jagadesh4java.blogspot.com/2014/05/perl-file-locking-using-flock.html#sthash.DHnEkfHD.dpuf


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

    release_lock(\$xfh);
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
    (my $hashref,my $debug,my $restTime) = @_;
    my %HoH = %$hashref;

    sleep($restTime);

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



#http://jagadesh4java.blogspot.com/2014/05/perl-file-locking-using-flock.html
#Sub Routine to Check Whether the Lock File Exists
sub check_lock_exists() {


   my $lock_file = shift || $XLOCKFILE;
   my $status;
   if (-e $lock_file) {
        $status = 0;
    } else {
        $status  = 1;
    }
   return $status;
 }

#end check_lock_exists



my $LOCK_EXCLUSIVE         = 2;
my $UNLOCK                 = 8;
my $LOCK_SHARED            = 1;
my $LOCK_NONBLOCKING       = 4;
#http://jagadesh4java.blogspot.com/2014/05/perl-file-locking-using-flock.html#sthash.AdUHHYMI.dpuf

sub get_lock()    {


     my $lock_file = shift || "kmem.lock";
     open (my $fh, ">>$lock_file") || die "problem opening lock File\n";
     flock $fh, $LOCK_EXCLUSIVE;
     return $fh;
     #print "----Obtained Lock----\n";

     #sleep 20;

     #flock FILE, $UNLOCK;
     #close(FILE);
     #unlink($lock_file) or die "can't remove lockfile: $lockfile ($!)";

}#end get_lock

sub release_lock(){
    my $fh = shift;
    my $lock_file = shift || $XLOCKFILE;
    flock $$fh, $UNLOCK;
    close($$fh) or die "Could not write '$lock_file' - $!";
    unlink($lock_file) or die "can't remove lockfile: $lock_file ($!)";
}#end release_lock
#http://jagadesh4java.blogspot.com/2014/05/perl-file-locking-using-flock.html#sthash.AdUHHYMI.dpuf


#http://www.perlmonks.org/?node_id=886569
#
#mimac mailx flag
#

#sub main(){

my $stime;
my $sevent;
my $result = GetOptions (
  "s=s" => \$sevent,
  "t:s"   => \$stime,
  #"optlist=s" => \@list,
);
print "$stime\n";
print "$sevent\n";
#}
#my( @opt_s, @opt_t );

#GetOptions(
#           's=s{1}' => \@opt_s,
#           't=s{1}' => \@opt_t,
#          );

#say "@opt_s";
#say "@opt_t";


#my %options = ();
#GetOptions (
#             "s=s" => \$options{'a'},
#             "t:s" => \$options{'b'},
             #"z!"  => \$options{'z'},
#            );

#my $sevent = '';
#GetOptions ('-s=s' => \$sevent);#'=' is required
#print "$sevent\n";
#my $stime = '';
#GetOptions ('-t:s' => \$stime);#':' is optional
#print "$stime\n";
#my $sdump = '';
#GetOptions ('-d:s' => \$sdump);#':' is optional
#print "$sdump\n";

#my %h2=&file2hash("kconfig");

#qd test
#my %hh2;
#my %mm2;
if ($stime=="2016"){
     my %hh2=&file2hash("kconfig");
    hash2print(\%hh2,0,5);
}
elsif($stime=="2017"){
    my %mm2=&file2hash("kmem");
    hash2print(\%mm2,0,5);
}
#}
#hash2print(\%m2,0,5);
#print &getDate();
#my $xcnt= &dispatch("event_c3_z2");
#&dispatch("event_c3_z2",0,"echo");
#&dispatch("event_c3_z2",1);
#print $xcnt;






