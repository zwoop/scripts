#!/bin/bash
#
# remdiff.sh: Diff local files against the same files remotely.
# -----------      Copyright (C) 2007  Leif Hedstrom <leif@ogre.com>
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
: ${DIFF=diff}

do_help() {
    echo "remdiff: Diff local files against the same files on a remote host"
    echo
    echo "Options:"
    echo "	-H | --host	Remote host name (SSH access required)"
    echo "	-h | --help	Sort the VM list by name"
}


# Parse the arguments
TEMP=`getopt -o H:h -l host:,help -n 'remdiff' -- "$@"`
if [ $? != 0 ] ; then
    echo "Terminating..." >&2
    exit 1
fi

host="unknown"
eval set -- "$TEMP"
while true ; do
    case "$1" in
	-H|--host)
	    host="$2"
	    shift 2
	    ;;
	-h|--help)
	    do_help
	    exit 0
	    ;;
	--) shift ; break ;;
	*) echo "Internal error!" ; exit 1 ;;
    esac
done

if [ "x$host" = "xunknown" ]; then
    echo "-h|--host is required, and takes an argument"
    exit
fi

# Loop over the remaining files
for f in $*; do
    $DIFF -N -u $f <(ssh -n ${host} cat ${f})
done
