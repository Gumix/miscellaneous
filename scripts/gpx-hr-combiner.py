#!/opt/local/bin/python

#import sys
#import time
from lxml import etree, objectify
import gpxpy

hr_file = open('/Users/gum/Desktop/to/hr.xml', 'r')
hr_tree = objectify.parse(hr_file)
hr_root = hr_tree.getroot()

hr_arr = {}
for lap in hr_root.Activities.Activity.Lap:
    for track in lap.Track:
        for point in track.Trackpoint:
            time = point.Time.pyval.rpartition('.')[0] + 'Z'
            hr_arr[time] = point.HeartRateBpm.Value

gps_file = open('/Users/gum/Desktop/to/gps.gpx', 'r')
#gps = gpxpy.parse(gps_file)
gps_tree = objectify.parse(gps_file)
gps_root = gps_tree.getroot()
for trk in gps_root.trk:
    for trkseg in trk.trkseg:
        for trkpt in trkseg.trkpt:
            if '{0}'.format(trkpt.time) in hr_arr:
                hr = hr_arr['{0}'.format(trkpt.time)]
            # else:
            #     hr = 100
            ext1 = objectify.SubElement(trkpt, 'extensions')
            ext2 = objectify.SubElement(ext1, 'TrackPointExtension')
            ext3 = etree.Element("thisdoesntmatter")
            ext3.tag = "thisdoesntmattereither"
            ext3.text = str(hr)
            ext2.hr = ext3

print etree.tostring(gps_tree, pretty_print=True)
