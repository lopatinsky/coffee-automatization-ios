import os.path
import plistlib
import urllib2
import json
import glob
 
root = '../DoubleB/Targets'
res = open('Targets.txt', 'w+')
sep = '\n'
 
for d in os.listdir(root):
    if os.path.isdir(os.path.join(root, d)):
        for f in glob.glob('%s/*.plist' % os.path.join(root, d)):
            pl = plistlib.readPlist(f)
            if 'CFBundleIdentifier' in pl:
                response = urllib2.urlopen('https://itunes.apple.com/lookup?bundleId=%s' % pl['CFBundleIdentifier'])
                data = json.load(response)  
                track_id = [result.get('trackId') for result in data.get('results')]
                print pl['CFBundleIdentifier'], track_id
                res.write('%s %s %s%s' % (d, pl['CFBundleIdentifier'], None if len(track_id)==0 else track_id[0] , sep))
res.close()