#!/usr/bin/perl
use strict;
use warnings;

&foo (bar=>"1");

sub foo {
    my %args=@_;
    my %defaults=(foo=>9, bar=>8, baz=>7);
    foreach (keys %defaults) {
        defined ($args{$_})  || {$args{$_}= $defaults{$_}} ;
        print $_ ," - ",$args {$_},"\n";
    }
}