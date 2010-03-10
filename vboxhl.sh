#!/bin/sh
#
# vboxhl.sh: Simple script to interactively start/stop headless VirtualBox VMs
# ---------      Copyright (C) 2007  Leif Hedstrom <leif@ogre.com>
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

: ${DIALOG=dialog}

# TMP files
DIAGFILE="/tmp/$(basename $0).$$.diag"
VBOXFILE="/tmp/$(basename $0).$$.vbox"

# cleanup
trap "rm -f $DIAGFILE $VBOXFILE" 0 1 2 5 15

do_start() {
    echo "\"\"" "\"\"" > $VBOXFILE
    VBoxManage  list vms | awk -F\" '/\"/ {printf "\"%s\" %s\n", $2, $3}' | $sort >> $VBOXFILE

    $DIALOG --clear --title "Start VirtualBox (headless)" \
	--menu "Select a VM from the list below:" 0 0 0 \
	--file $VBOXFILE  2> $DIAGFILE

    retval=$?

    choice=`cat $DIAGFILE`
    clear

    case $retval in
	0)
	    if [ "$choice" != "" ]; then
		echo "Starting $choice..."
		VBoxManage startvm "$choice" --type headless
	    fi
	    ;;
    esac
}


do_kill() {
    echo "\"\"" "\"\"" > $VBOXFILE
    VBoxManage list runningvms | awk -F\" '/\"/ {printf "\"%s\" %s\n", $2, $3}' | $sort >> $VBOXFILE
    $DIALOG --clear --title "Kill VirtualBox instance (headless)" \
	--menu "Select a VM from the list below:" 0 0 0 \
	--file $VBOXFILE  2> $DIAGFILE

    retval=$?

    choice=`cat $DIAGFILE`
    clear

    case $retval in
	0)
	    if [ "$choice" != "" ]; then
		echo "Starting $choice..."
		VBoxManage controlvm "$choice" poweroff
	    fi
	    ;;
    esac
}

do_help() {
    echo "vboxhl: Start / stop headless VirtualBox instances"
    echo
    echo "Options:"
    echo "	-s | --start	Select a VM to start"
    echo "	-k | --kill	Select a VM to kill"
    echo "	-S | --sort	Sort the VM list by name"
}

PARGS=`getopt -o skSh --long stop,kill,sort,help -n 'vboxhl' -- "$@"`

if [ $? != 0 ] ; then
    echo "Terminating..." >&2 
    exit 1
fi

eval set -- "$PARGS"

sort="cat"

while true; do
    case "$1" in
	-s|--start)
	    do_start
	    exit 0
	    ;;
	-k|--kill)
	    do_kill
	    exit 0
	    ;;
	-S|--sort)
	    sort="sort"
	    shift;
	    ;;
	-h|--help)
	    do_help
	    exit 0
	    ;;
	--) shift
	    break
	    ;;
        *)
	    echo "Internal error!"
	    exit 1
	    ;;
    esac
done

# If we get here, none of -s or -k was given, so default to "start"
do_start
