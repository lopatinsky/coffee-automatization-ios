import os
import glob
import sys
import shutil
import subprocess
import plistlib

#============
# Modifiers
MDF_LIVE = '--live'
#============

#============
# Args

ARG_APP_NAME = '-n'
ARG_BUNDLE_ID = '-id'
ARG_URL_NAMESPACE = '-urln'
ARG_APP_COLOR = '-c' # App color in format #ffffff
ARG_ICON_PATH = '-ipath'
ARG_LAUNCH_IMAGE_PATH = '-lpath'

#============

def parse_script_args():
	args = {}
	for i in xrange(1, len(sys.argv)):
		key = sys.argv[i]
		if is_arg(key):
			value = sys.argv[i+1]
			if not(is_arg(value) and is_modifier(value)):
				args[key] = value

	return args

def is_arg(value):
	return value in [ARG_APP_NAME, ARG_BUNDLE_ID, ARG_URL_NAMESPACE, ARG_APP_COLOR, ARG_ICON_PATH, ARG_LAUNCH_IMAGE_PATH]


def parse_script_modifiers():
	mdfs = []
	for i in xrange(1, len(sys.argv)):
		mdf = sys.argv[i]
		if is_modifier(mdf):
			mdfs += [mdf]

	return mdfs

def is_modifier(value):
	return value == MDF_LIVE



new_app_name = ''
new_app_path = ''
new_bundle_id = ''
base_url_namespace = ''
new_app_color = ''
icon_path = ''
launch_path = ''

script_modifiers = parse_script_modifiers()
if MDF_LIVE in script_modifiers:
	new_app_name = raw_input('App Name: ')
	new_app_path = new_app_name

	new_bundle_id = raw_input('App bindle id: ')

	base_url_namespace = raw_input('App url namespace: ')
	new_app_color = raw_input('App color in format #ffffff: ')

	icon_path = raw_input('App icon: ')
	launch_path = raw_input('App launch image: ')
else:
	script_args = parse_script_args()

	new_app_name = script_args.get(ARG_APP_NAME, "")
	new_app_path = new_app_name

	new_bundle_id = script_args.get(ARG_BUNDLE_ID, "")

	base_url_namespace = script_args.get(ARG_URL_NAMESPACE, "")
	new_app_color = script_args.get(ARG_APP_COLOR, "")

	icon_path = script_args.get(ARG_ICON_PATH, "")
	launch_path = script_args.get(ARG_LAUNCH_IMAGE_PATH, "")


shutil.copytree("templateApp", new_app_path)

# Rename plist
plist_path = "%s/%s" % (new_app_path, "info.plist")
new_plist_path = "%s/%s-%s" % (new_app_path, new_app_name, "info.plist")
os.rename(plist_path, new_plist_path)

# Modify plist
pl = plistlib.readPlist(new_plist_path)
pl['CFBundleIdentifier'] = new_bundle_id
plistlib.writePlist(pl, new_plist_path)

# Modify CompanyInfo.plist
company_plist_path = "%s/CompanyInfo.plist" % new_app_path
pl = plistlib.readPlist(company_plist_path)
if(base_url_namespace != ""):
	pl['Preferences']['BaseUrl'] = "http://%s.1.doubleb-automation-production.appspot.com/" % base_url_namespace
if(new_app_color != ""):
	pl['Preferences']['CompanyColor'] = new_app_color
plistlib.writePlist(pl, company_plist_path)

# Rename assets
assets_path = "%s/%s" % (new_app_path, "Images.xcassets")
new_assets_path = "%s/%s-%s" % (new_app_path, new_app_name, "Images.xcassets")
os.rename(assets_path, new_assets_path)

# Set icons
if(icon_path != ""):
	new_app_icons_path = "%s/AppIcon.appiconset" % (new_assets_path)
	cmd = "python i.py %s %s" % (icon_path, new_app_icons_path)
	os.system(cmd)

# Set Launch
if(launch_path != ""):
	new_app_launch_images_path = "%s/LaunchImage.launchimage" % (new_assets_path)
	cmd = "python l.py %s %s" % (launch_path, new_app_launch_images_path)
	os.system(cmd)

	# Set additional launch
	new_app_additional_launch_images_path = "%s/AdditionalResources/Resources" % (new_app_path)
	cmd = "python l.py %s %s" % (launch_path, new_app_additional_launch_images_path)
	os.system(cmd)