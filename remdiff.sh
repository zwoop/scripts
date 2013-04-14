#!/bin/bash
#
# remdiff.sh: Diff local files against the same files remotely.
# -----------      Copyright (C) 2007  Leif Hedstrom <leif@ogre.com>
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
