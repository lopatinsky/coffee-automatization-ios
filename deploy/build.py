import os
import shutil
import plistlib
import urllib2
import json
import glob
import subprocess
 
DEV_ACCOUNT = 'isoschepkov@gmail.com'
PASSWORD = ''

PROJECT_NAME = 'DoubleB'
DEBUG_SKIP_BUILD_STEP = False      # set to 1 if you don't want to clean and rebuild ipa files
DEBUG_SKIP_UPLOAD_STEP = True  # set to 1 if you don't want the built ipa files to be uploaded

path_output = "build" 
project_file = "../%s.xcodeproj" % PROJECT_NAME
workspace_file = "../%s.xcworkspace" % PROJECT_NAME

temp_file = "temp.tmp"

def schemes_list():
	with open(temp_file, "w") as f:
		cmd = "xcodebuild -list -project".split()
		cmd += [project_file]

		if subprocess.call(cmd, stdout=f) != 0:
			print "nonzero exit code"

	with open(temp_file) as f:
		lines = f.readlines()

	os.remove(temp_file)

	start = lines.index("    Schemes:\n") + 1
	schemes = [l.strip() for l in lines[start:]]

	return schemes

def print_schemes(schemes):
	i = 0
	for scheme in schemes:
		i += 1
		print '%s. %s' % (i, scheme) 

def clean_folder(path_to_folder):
	for the_file in os.listdir(path_to_folder):
	    file_path = os.path.join(path_to_folder, the_file)
	    try:
	        if os.path.isfile(file_path):
	            os.unlink(file_path)
	        #elif os.path.isdir(file_path): shutil.rmtree(file_path)
	    except Exception, e:
	        print e

def build_schemes(schemes):
	i = 0
	for scheme in schemes:
		print
		i+=1
		print "Building scheme %s/%s" % (i, len(schemes))
		build_scheme(scheme)

def build_scheme(scheme):
	cmd = "ipa build -w %s -s %s -c AppStore -d %s" % ("/Users/ivanoschepkov/Development/Empatika/coffee-automatization-ios/DoubleB.xcworkspace", scheme, path_output)
	cmd = cmd.split()
	print cmd
	with open(temp_file, "w") as f:
		if subprocess.call(cmd, stdout=f) != 0:
			print "nonzero exit code"

	with open(temp_file) as f:
		lines = f.readlines()

	# os.remove(temp_file)
	print lines

all_schemes = schemes_list()
print_schemes(all_schemes)
selected_scheme_nums = raw_input('Targets: ')
selected_scheme_nums = selected_scheme_nums.split()

selected_schemes = []
for num in selected_scheme_nums:
	selected_schemes += [all_schemes[int(num) - 1]]
schemes_count = len(selected_schemes)

clean_folder(path_output)

#============
# Build
#============
if not DEBUG_SKIP_BUILD_STEP:
	clean_folder(path_output)

	print "*** Start building ..."
	print "All schemes (%s):" %schemes_count
	print selected_schemes

	build_schemes(selected_schemes)
else:
	print "*** SKIPPING build step ..."

#============
# Upload
#============
# if not DEBUG_SKIP_UPLOAD_STEP:
# else:	

