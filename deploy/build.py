import os.path
import plistlib
import urllib2
import json
import glob
import subprocess
 
DEV_ACCOUNT = 'isoschepkov@gmail.com'
PASSWORD = ''

PROJECT_NAME = 'DoubleB'
DEBUG_SKIP_BUILD_STEP = 0      # set to 1 if you don't want to clean and rebuild ipa files
DEBUG_SKIP_UPLOAD_STEP = 1  # set to 1 if you don't want the built ipa files to be uploaded

path_output = 'build/' 
workspace_file = "../%s.xcodeproj" % PROJECT_NAME

with open("schemes.tmp", "w") as f:
	cmd = "xcodebuild -list -project".split()
	cmd += [workspace_file]

	if subprocess.call(cmd, stdout=f) != 0:
		print "nonzero exit code"

# print schemes
with open("schemes.tmp") as f:
	lines = f.readlines()

start = lines.index("    Schemes:\n") + 1
schemes = [l.strip() for l in lines[start:]]
print schemes
