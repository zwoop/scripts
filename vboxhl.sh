#!/bin/sh
#
# vboxhl.sh: Simple script to interactively start/stop headless VirtualBox VMs
# ---------      Copyright (C) 2007  Leif Hedstrom <leif@ogre.com>
#
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
    echo "	-h | --help	Show help"
}

TEMP=`getopt -o skSh --long stop,kill,sort,help -n 'vboxhl' -- "$@"`

if [ $? != 0 ] ; then
    echo "Terminating..." >&2 
    exit 1
fi

eval set -- "$TEMP"

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
