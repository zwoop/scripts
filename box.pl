#!/usr/bin/perl
#
# box.pl: Draw simple ANSI box around text, inspired from LiTH hackage days.
# ------      Copyright (C) 2007  Leif Hedstrom <leif@ogre.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
use strict;
use warnings;

use Getopt::Std;

# Parse command line args
my %opts;
getopts('cl:', \%opts);

# Try to get the terminal width
my $term_width = 80;
unless ($opts{l}) {
  eval 'use Term::ReadKey';
  unless ($@) {
    my ($cols,$lines) = GetTerminalSize();

    $term_width = $cols if ($cols && $cols > 0);
  }
}

# Setup
my @lines;
my $max_len = 0;
my $indent;
my $width = $opts{l} || $term_width;

while(<>) {
  chomp;
  s/\t/        /g;
  my $len = length($_);

  push(@lines, $_);
  $max_len = $len if $len > $max_len
}
$width = $max_len if $max_len > $width;

$indent = int(($width - 4 - $max_len) / 2);

# Top "frame"
print " " x $indent if $opts{c};
print "(0l";(B
(0print(B (0"q"(B (0x(B (0($max_len(B (0+(B (02);(B
(0print(B (0"k(B\n";

# lines
foreach (@lines) {
  print " " x $indent if $opts{c};
  print "(0x(B";
  print " $_ ";
  print " " x ($max_len - length($_));
  print "(0x(B\n";
}

# Bottom frame
print " " x $indent if $opts{c};
print "(0m";(B
(0print(B (0"q"(B (0x(B (0($max_len(B (0+(B (02);(B
(0print(B (0"j(B\n";
