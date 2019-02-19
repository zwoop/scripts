#!/usr/bin/python
#
# procdelta.py: Generate some 'stats' from /proc CPU usage, for some
# ------------  given amount of time interval. This allows you to see
#               what your CPUs are doing during a test run. This almost
#               certainly only works on Linux, and I'm sure there are
#               better tools that does something similar...
#
#               Copyright (C) 2007  Leif Hedstrom <leif@ogre.com>
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
import time
import getopt
import sys
import os


class ProcParser(object):
    _SC_CLK_TCK = float(os.sysconf("SC_CLK_TCK"))

    def __init__(self, f=None):
        if (not f):
            f = "/proc/stat"
        try:
            fd = open(f, "r")
        except IOError, msg:
            print "Can't open /proc/stat: ", msg
            fd = None
        self._started = time.time()
        self._run_for = 0
        self._data = {}
        self._parse(fd)

    def _parse(self, fd):
        for l in fd.readlines():
            d = l.split()
            self._data[d[0]] = [int(x) for x in d[1:]]

    def delta(self, other):
        new = ProcParser("/dev/null")
        new._run_for = self._started - other._started
        for k in self._data.keys():
            new._data[k] = [self._data[k][x]-other._data[k][x] for x in range(0, len(self._data[k]))]

        return new

    def __str__(self):
        s = " CPU     USER     NICE     SYS      IDLE     Wait     IRQ      SIRQ\n"
        s += "-----   ------   ------   ------   ------   ------   ------   ------\n"
        tags = self._data.keys()
        tags.sort()

        for k in tags:
            if k.startswith("cpu"):
                s += " %-4s  %6.1f%%  %6.1f%%  %6.1f%%  %6.1f%%  %6.1f%%  %6.1f%%  %6.1f%%\n" % (
                    k,
                    (100 * self._data[k][0] / self._SC_CLK_TCK) / self._run_for,
                    (100 * self._data[k][1] / self._SC_CLK_TCK) / self._run_for,
                    (100 * self._data[k][2] / self._SC_CLK_TCK) / self._run_for,
                    (100 * self._data[k][3] / self._SC_CLK_TCK) / self._run_for,
                    (100 * self._data[k][4] / self._SC_CLK_TCK) / self._run_for,
                    (100 * self._data[k][5] / self._SC_CLK_TCK) / self._run_for,
                    (100 * self._data[k][6] / self._SC_CLK_TCK) / self._run_for)

        s += "\n\nContext switches/sec:   %.1f\n" % (self._data["ctxt"][0] / self._run_for)
        s += "Interrupts/sec: %.1f\n" % (self._data["intr"][0] / self._run_for)
        return s


def usage_exit(msg=None):
    if msg:
        print "Error: ",
        print msg
        print
    print """\
Usage: procdelta [options] [file1 file2]

Options:
  -h, --help         Show this message
  -i, --interval     Collect two /proc/stat data sets at this interval
  """
    sys.exit(2)


if __name__ == "__main__":

    # Options/settings
    params = {'interval': 0,
              }

    try:
        options, args = getopt.getopt(sys.argv[1:],
                                      'hHi:',
                                      ['help',
                                       'interval=',
                                       ])
        for opt, value in options:
            if opt in ('-h', '-H', '--help'):
                usage_exit()
            elif opt in ('-i', '--interval'):
                params['interval'] += int(value)

    except getopt.error, msg:
        usage_exit(msg)

    if len(args) == 2:
        t0 = ProcParser(args[0])
        t1 = ProcParser(args[1])
    elif (params["interval"] > 0):
        t0 = ProcParser()
        time.sleep(params["interval"])
        t1 = ProcParser()
    else:
        usage_exit()

    d = t1.delta(t0)
    print d


#
# local variables:
# mode: python
# indent-tabs-mode: nil
# py-indent-offset: 4
# end:
