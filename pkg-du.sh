#!/bin/sh
#
# pkg-du.sh: Simple script to find disk space used by installed packages.
# ----------
#
# Author: Leif Hedstrom <zwoop@apache.org>
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
