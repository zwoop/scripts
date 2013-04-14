#!/bin/sh
#
# pkg-du.sh: Simple script to find disk space used by installed packages.
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

# Shared across package managers, $DATA holds all the active files for the pkg
du_files() {
    if [ -f $DATA ]; then
	du -Ssc `cat $DATA` 2> /dev/null | awk '/total/ {print $1}'
    else
	echo "0"
    fi
    rm -f $DATA || exit 1
}


# For Ubuntu and other "deb" style package managers.
do_dpkg() {
    for pkg in $(dpkg --get-selections | awk '/install/ {print $1}'); do
	echo -n "$pkg	"
	for f in $(dpkg -L $pkg); do
	    if [ -f "$f" ]; then
		echo $f >> $DATA
	    fi
	done
	du_files
    done
}

# For Fedora / RedHat (and other RPM based package systems)
do_rpm() {
    for pkg in $(rpm -qa); do
	echo -n "$pkg	"
	for f in $(rpm -q -l $pkg); do
	    if [ -f "$f" ]; then
		echo $f >> $DATA
	    fi
	done
	du_files
    done
}

#
# Main / start
#
# TODO: Add command line parsing, supporting
#    - Sorted output
#
DATA="/tmp/dpkgdu.$$"
rm -f $DATA || exit 1

trap "[ -f $DATA ] && rm -f $DATA; exit 1" 0 1 2 3 15

if [ -x /usr/bin/dpkg -o -x /bin/dpkg ]; then
    do_dpkg
elif [ -x /bin/rpm -o -x /usr/bin/rpm ]; then
    do_rpm
else
    echo "Platform not supported!"
fi
