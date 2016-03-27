import os, sys, getopt
from PIL import Image, ImageOps

icon_size_classes = [
    [(58, 58), 'icon_settings@2x'],
    [(87, 87), 'icon_settings@3x'],
    [(80, 80), 'icon_spotlight@2x'],
    [(120, 120), 'icon_spotlight@3x'],
    [(120, 120), 'icon@2x'],
    [(180, 180), 'icon@3x'],
    [(29, 29), 'icon_ipad_settings'],
    [(58, 58), 'icon_ipad_settings@2x'],
    [(40, 40), 'icon_ipad_spotlight'],
    [(80, 80), 'icon_ipad_spotlight@2x'],
    [(76, 76), 'icon_ipad'],
    [(152, 152), 'icon_ipad@2x'],
]

splash_size_classes = [
    [(1242, 2208), 'launch_736'],
    [(750, 1334), 'launch_667'],
    [(640, 1136), 'launch_568'],
    [(640, 960), 'launch_480']
]

assets_contents_json = \
'''
{
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
'''

icons_contents_json = \
'''
{
    "images" : [
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "icon_settings@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "icon_settings@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "icon_spotlight@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "icon_spotlight@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "icon@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "icon@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "icon_ipad_settings.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "icon_ipad_settings@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "icon_ipad_spotlight.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "icon_ipad_spotlight@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "icon_ipad.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "icon_ipad@2x.png",
      "scale" : "2x"
    },
    {
      "idiom" : "ipad",
      "size" : "83.5x83.5",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "unassigned" : true,
      "scale" : "2x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
'''

splash_contents_json = \
'''
{
  "images" : [
    {
      "extent" : "full-screen",
      "idiom" : "iphone",
      "subtype" : "736h",
      "filename" : "launch_736.png",
      "minimum-system-version" : "8.0",
      "orientation" : "portrait",
      "scale" : "3x"
    },
    {
      "extent" : "full-screen",
      "idiom" : "iphone",
      "subtype" : "667h",
      "filename" : "launch_667.png",
      "minimum-system-version" : "8.0",
      "orientation" : "portrait",
      "scale" : "2x"
    },
    {
      "orientation" : "portrait",
      "idiom" : "iphone",
      "filename" : "launch_480.png",
      "extent" : "full-screen",
      "minimum-system-version" : "7.0",
      "scale" : "2x"
    },
    {
      "extent" : "full-screen",
      "idiom" : "iphone",
      "subtype" : "retina4",
      "filename" : "launch_568.png",
      "minimum-system-version" : "7.0",
      "orientation" : "portrait",
      "scale" : "2x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
'''


def create_folder(path):
    if not os.path.exists(path):
        os.makedirs(path)


def create_assets(project_name, icons_exists=False, splash_exists=False):
    assets_folder = os.path.join(project_name, project_name + '-Images.xcassets')
    icons_assets_folder = os.path.join(assets_folder, 'AppIcon.appiconset')
    splash_assets_folder = os.path.join(assets_folder, 'LaunchImage.launchimage')

    assets_contents = os.path.join(assets_folder, 'Contents.json')
    icons_contents = os.path.join(icons_assets_folder, 'Contents.json')
    splash_contents = os.path.join(splash_assets_folder, 'Contents.json')

    create_folder(assets_folder)
    create_folder(icons_assets_folder)
    create_folder(splash_assets_folder)

    with open(assets_contents, 'w+') as contents:
        contents.write(assets_contents_json)

    if icons_exists:
        with open(icons_contents, 'w+') as contents:
            contents.write(icons_contents_json)

    if splash_exists:
        with open(splash_contents, 'w+') as contents:
            contents.write(splash_contents_json)

    return icons_assets_folder, splash_assets_folder


def generate_icons(project_name, path, icon_name):
    for size_class in icon_size_classes:
        outfile = size_class[1]
        try:
            im = Image.open(icon_name)
            im.thumbnail(size_class[0], Image.ANTIALIAS)
            im.save(os.path.join(path, outfile + '.png'), "PNG")
        except IOError as e:
            print(e)
    try:
        im = Image.open(icon_name)
        im.thumbnail((1024, 1024), Image.ANTIALIAS)
        im.save(os.path.join(project_name, 'icon_appstore.jpg'), "JPEG", quality=100, optimize=True, progressive=True)
    except IOError as e:
        print(e)


def generate_splashes(project_name, path, splash_name):
    additional_path1 = os.path.join(project_name, 'AdditionalResources')
    additional_path2 = os.path.join(additional_path1, 'Resources')
    create_folder(additional_path1)
    create_folder(additional_path2)

    for size_class in splash_size_classes:
        outfile = size_class[1]
        try:
            im = Image.open(splash_name)
            im.thumbnail(size_class[0], Image.ANTIALIAS)
            im = im.resize(size_class[0], Image.ANTIALIAS)
            im.save(os.path.join(path, outfile + '.png'), "PNG")
            im.save(os.path.join(additional_path2, outfile + '.png'), "PNG")
        except IOError as e:
            print(e)


def generate_assets(project_name, icon_name=None, splash_name=None):
    create_folder(project_name)
    icons_path, splash_path = create_assets(project_name, icon_name is not None, splash_name is not None)
    if icon_name is not None:
        generate_icons(project_name, icons_path, icon_name)
    if splash_name is not None:
        generate_splashes(project_name, splash_path, splash_name)


def main(argv):
    project_name = ''
    icon_name = ''
    splash_name = ''
    try:
        opts, args = getopt.getopt(argv,"hp:i:s:",["project=","icon=","splash="])
    except getopt.GetoptError:
        print 'test.py -p <project_name> -i <icon_name> -s <splash_name>, ' \
            'use "_" for optional values'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'test.py -p <project_name> -i <icon_name> -s <splash_name>, ' \
                'use "_" for optional values'
            sys.exit()
        elif opt in ("-p", "--project"):
            project_name = arg
        elif opt in ("-i", "--icon"):
            icon_name = arg
        elif opt in ("-s", "--splash"):
            splash_name = arg

    generate_assets(
        project_name,
        icon_name if icon_name != '_' else None,
        splash_name if splash_name != '_' else None
    )


if __name__ == "__main__":
   main(sys.argv[1:])
