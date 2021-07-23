#!/usr/bin/env perl

use strict;
use warnings;
use diagnostics;  # TODO: disable in prod

use Time::Piece;
use Time::Seconds;

sub main {
    my ($t, $end) = map { Time::Piece->strptime($_, "%Y-%m-%d") } @ARGV; 
    while ($t <= $end) {
        my $formatted = $t->strftime("%a %Y-%m-%d");
        print "$formatted\n";
        $t += ONE_DAY;
    }
}

main();
