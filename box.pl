#!/usr/bin/perl
#                                           -*- coding: no-conversion -*- 
#
# box.pl: Draw simple ANSI box around text.
# Copyright (C) 2007  Leif Hedstrom <leif@ogre.com>
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
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
print "(0l";
print "q" x ($max_len + 2);
print "k(B\n";

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
print "(0m";
print "q" x ($max_len + 2);
print "j(B\n";
