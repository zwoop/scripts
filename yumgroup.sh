#!/bin/sh
#
# yumgroup.sh: Simple script to manage yum groups.
# ---------    Copyright (C) 2011  Leif Hedstrom <leif@ogre.com>
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

: ${DIALOG=dialog}

: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

MYSELF=$(basename $0)

# TMP files
DIAGFILE="/tmp/$MYSELF.$$.diag"
YUMGFILE="/tmp/$MYSELF.$$.yumg"

# cleanup
trap "rm -f $DIAGFILE $YUMGFILE" 0 1 2 5 15

gen_installed() {
    in_inst=0
    OLD_IFS=$IFS
    IFS="
"
    for l in $(yum grouplist); do
        if [ "Installed Groups:" == $l ]; then
            in_inst=1
        elif [ "Available Groups:" == $l ]; then
            in_inst=0
        elif [ $in_inst == "1" ]; then
            echo "\"$l\" \"\" off" >>$YUMGFILE
        fi
    done
    IFS=$OLD_IFS
}

gen_available() {
    in_avail=0
    OLD_IFS=$IFS
    IFS="
"
    for l in $(yum grouplist); do
        if [ "Available Groups:" == $l ]; then
            in_avail=1
        elif [ "Done" == "$l" ]; then
            in_avail=0
        elif [ $in_avail == "1" ]; then
            echo "\"$l\" \"\" off" >>$YUMGFILE
        fi
    done
    IFS=$OLD_IFS
}

do_update() {
    gen_installed

    $DIALOG --clear --title "Upgrade yum groups" \
        --checklist "Select one or several groups from below to upgrade" 0 0 0 \
        --file $YUMGFILE 2>$DIAGFILE

    retval=$?

    choice=$(cat $DIAGFILE)
    clear

    case $retval in
    $DIALOG_OK)
        OLD_IFS=$IFS
        IFS="\"
"
        for word in $(<$DIAGFILE); do
            if [[ $word =~ [A-Z,a-z] ]]; then
                echo ">>> Starting upgrade of $word <<<"
                yum groupupdate "$word"
            fi
        done
        IFS=$OLD_IFS
        ;;
    esac
}

do_remove() {
    gen_installed

    $DIALOG --clear --title "Remove yum groups" \
        --checklist "Select one or several groups from below to remove" 0 0 0 \
        --file $YUMGFILE 2>$DIAGFILE

    retval=$?
    clear

    case $retval in
    $DIALOG_OK)
        OLD_IFS=$IFS
        IFS="\"
"
        for word in $(<$DIAGFILE); do
            if [[ $word =~ [A-Z,a-z] ]]; then
                echo ">>> Starting removal of $word <<<"
                yum groupremove "$word"
            fi
        done
        IFS=$OLD_IFS
        ;;
    esac
}

do_install() {
    gen_available

    $DIALOG --clear --title "Add yum groups" \
        --checklist "Select one or several groups from below to install" 0 0 0 \
        --file $YUMGFILE 2>$DIAGFILE

    retval=$?
    clear

    case $retval in
    $DIALOG_OK)
        OLD_IFS=$IFS
        IFS="\"
"
        for word in $(<$DIAGFILE); do
            if [[ $word =~ [A-Z,a-z] ]]; then
                echo ">>> Starting install of $word <<<"
                yum groupinstall "$word"
            fi
        done
        IFS=$OLD_IFS
        ;;
    esac
}

do_help() {
    echo "yumgroup.sh: Manage yum groups interactively from command line"
    echo
    echo "Options:"
    echo "      -u | --update   Select yum groups to update"
    echo "      -r | --remove   Select yum groups to remove"
    echo "      -i | --install  Select yum groups to install"
}

PARGS=$(getopt -o urih --long update,remove,install,help -n "$MYSELF" -- "$@")

if [ $? != 0 ]; then
    echo "Terminating..." >&2
    exit 1
fi

eval set -- "$PARGS"

sort="cat"

while true; do
    case "$1" in
    -u | --update)
        do_update
        exit 0
        ;;
    -r | --remove)
        do_remove
        exit 0
        ;;
    -i | --install)
        do_install
        exit 0
        ;;
    -h | --help)
        do_help
        exit 0
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Internal error!"
        exit 1
        ;;
    esac
done

# If we get here, none of -s or -k was given, so default to "start"
do_update
