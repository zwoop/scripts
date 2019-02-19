# Leif's Scripts

All scripts in this area are releaed into the public domain under the
Apache License, by me, Leif Hedstrom.

      Copyright (C) 2007  Leif Hedstrom <leif@ogre.com>.


## box[.pl]

This little script was inspired by the old Late Night hacking at LiTH in
the 80's. It's useless, but cute. An example:


    $ fortune | box


## pkg-du[.sh]

This script, which supports .deb (e.g. Ubuntu) and RPM (e.g. Fedora Core)
systems, will examine all installed packages, and do a "du" on each
package. The output is not sorted (yet), but can easily be done in a
pipe. For example, use it like

    $ pkg-du | sort -nr -k2


## vboxhl[.sh]

Start (and kill) VirtualBox headless instances, from a little interactive
dialog menu. Usage:

       vboxhl: Start / stop headless VirtualBox instances

       Options:
		-s | --start	Select a VM to start
		-k | --kill	Select a VM to kill
		-S | --sort	Sort the VM list by name
		-h | --help	Show this help screen

## remdiff[.sh]

Diff a local file (or files) against the same file(s) on a remote
host. Usage:
      
      remdiff: Diff local files against the same files on a remote host

      Options:
		-H | --host	Remote host name (SSH access required)
		-h | --help	Sort the VM list by name


## procdelta[.py]

Run this on linux, during an interval where you are benchmarking an
app. This will show you an overall idea of what the CPU(s) are doing
during the benchmark. Usage:

       Usage: procdelta [options] [file1 file2]

       Options:
         -h, --help         Show this message
	 -i, --interval     Collect proc/stat data sets at this interval