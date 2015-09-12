import os, sys
from PIL import Image, ImageOps

size_classes = [
    [(1242, 2208), 'launch_736'],
    [(750, 1334), 'launch_667'],
    [(640, 1136), 'launch_568'],
    [(640, 960), 'launch_480']
]

icon_path = sys.argv[1]
output_path = sys.argv[2]


for size_class in size_classes:
    outfile = size_class[1]
    if icon_path != outfile:
        outfile = output_path + "/" + outfile
        try:
            im = Image.open(icon_path)
            if size_class[1] == "launch_480":
                im = im.resize((640, 1136), Image.ANTIALIAS)
                im = ImageOps.fit(im, size_class[0], Image.ANTIALIAS)
            else:
                im = im.resize(size_class[0], Image.ANTIALIAS)
            im.save(outfile + '.png', "PNG")
        except IOError:
            print "cannot create icon for '%s'" % icon_path
