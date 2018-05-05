#!/usr/bin/env python

""" This script allows to find GPX tracks that intersect the target area """

import os
import math
import argparse
import xml.etree.ElementTree as ET


def distance(p1, p2):
    lon1 = math.radians(float(p1['lon']))
    lat1 = math.radians(float(p1['lat']))
    lon2 = p2['lon']
    lat2 = p2['lat']

    a = (lon2 - lon1) * math.cos((lat1 + lat2) / 2)
    b = (lat2 - lat1)
    r = 6363720 # Earth radius at ground level for latitude 55.751244

    return math.sqrt(a * a + b * b) * r


def read_gpx(gpx_filename, target, radius):
    print("Processing %s " % gpx_filename, end='')

    try:
        tree = ET.ElementTree(file=gpx_filename)
    except FileNotFoundError as err:
        exit(err)
    except ET.ParseError as err:
        exit(err)

    ns = { 'gpx': 'http://www.topografix.com/GPX/1/1' }
    root = tree.getroot()
    if root.tag != '{%s}gpx' % ns['gpx']:
        exit("XML document of the wrong type, root node != gpx")

    for trk in root.findall('gpx:trk', ns):
        for trkseg in trk.findall('gpx:trkseg', ns):
            for trkpt in trkseg.findall('gpx:trkpt', ns):
                if distance(trkpt.attrib, target) <= radius:
                    print(True)
                    return
    print(False)


def read_dir(dir_name, target, radius):
    for f in os.listdir(dir_name):
        if not f.startswith('.'):
            f = os.path.join(dir_name, f)
            if os.path.isfile(f):
                read_gpx(f, target, radius)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('track_list', help="list of GPX tracks or directories with tracks")
    parser.add_argument('--lat', type=float, default=55.75, help="latitude of the target location")
    parser.add_argument('--lon', type=float, default=37.62, help="longitude of the target location")
    parser.add_argument('-r', '--radius', type=int, default=2500, help="radius around the target point (in meters)")
    args = parser.parse_args()
    target = { 'lat': math.radians(args.lat), 'lon': math.radians(args.lon) }

    try:
        f = open(args.track_list)
    except FileNotFoundError as err:
        exit(err)

    for track in f:
        track = track.rstrip()
        if os.path.isdir(track):
            read_dir(track, target, args.radius)
        else:
            read_gpx(track, target, args.radius)
    f.close()

if __name__ == '__main__':
    main()
