#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;


#( my $file=>'kconfig',  my $mem=>'kmem', my $debug=>0);


sub hello {
    my ($say,$to) = @_;
    $say ||= "Hello";
    $to ||= "World!";
    print "$say $to\n";
}

&hello();

hello("wonderful","universe");