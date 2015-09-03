import os
import glob
import sys
import shutil
import subprocess
import plistlib

#============
# Args

ARG_APP_NAME = "-n" # New App name
ARG_BUNDLE_ID = "-id" # New App bundle id
ARG_URL_NAMESPACE = "-urln" # Url namespace
ARG_APP_COLOR = "-c" # App color in format #ffffff
ARG_ICON_PATH = "-iconp" # App icon path
ARG_LAUNCH_IMAGE_PATH = "-lp" # App launch path

#============

def parse_script_args():
	args = {}
	for i in xrange(1, len(sys.argv), 2):
		args[sys.argv[i]] = sys.argv[i+1]

	return args


script_args = parse_script_args()
new_app_name = script_args.get(ARG_APP_NAME, "")

new_app_path = new_app_name

shutil.copytree("templateApp", new_app_path)

# Rename plist
plist_path = "%s/%s" % (new_app_path, "info.plist")
new_plist_path = "%s/%s-%s" % (new_app_path, new_app_name, "info.plist")
os.rename(plist_path, new_plist_path)

# Modify plist
new_bundle_id = script_args.get(ARG_BUNDLE_ID, "")

pl = plistlib.readPlist(new_plist_path)
pl['CFBundleIdentifier'] = new_bundle_id
plistlib.writePlist(pl, new_plist_path)

# Modify CompanyInfo.plist
base_url_namespace = script_args.get(ARG_URL_NAMESPACE, "")
new_app_color = script_args.get(ARG_APP_COLOR, "")

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
icon_path = script_args.get(ARG_ICON_PATH, "")
if(icon_path != ""):
	new_app_icons_path = "%s/AppIcon.appiconset" % (new_assets_path)
	cmd = "python i.py %s %s" % (icon_path, new_app_icons_path)
	os.system(cmd)

# Set Launch
launch_path = script_args.get(ARG_LAUNCH_IMAGE_PATH, "")
if(launch_path != ""):
	new_app_launch_images_path = "%s/LaunchImage.launchimage" % (new_assets_path)
	cmd = "python l.py %s %s" % (launch_path, new_app_launch_images_path)
	os.system(cmd)

	# Set additional launch
	new_app_additional_launch_images_path = "%s/AdditionalResources/Resources" % (new_app_path)
	cmd = "python l.py %s %s" % (launch_path, new_app_additional_launch_images_path)
	os.system(cmd)