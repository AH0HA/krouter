#!/usr/bin/perl
sub foo {
    %args=@_;
    %defaults=(foo=>9, bar=>8, baz=>7);
    foreach (keys %defaults) {
        defined ($args{$_})  || {$args{$_}= $defaults{$_}} ;
        print $_ ," - ",$args {$_},"\n";
    }
}

&foo (bar=>"1");