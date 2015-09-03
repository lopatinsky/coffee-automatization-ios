import os, sys
from PIL import Image

size_classes = [
    [(58, 58), 'icon_settings@2x.png'],
    [(87, 87), 'icon_settings@3x.png'],
    [(80, 80), 'icon_spotlight@2x.png'],
    [(120, 120), 'icon_spotlight@3x.png'],
    [(120, 120), 'icon@2x.png'],
    [(180, 180), 'icon@3x.png'],
    [(29, 29), 'icon_ipad_settings.png'],
    [(58, 58), 'icon_ipad_settings@2x.png'],
    [(40, 40), 'icon_ipad_spotlight.png'],
    [(80, 80), 'icon_ipad_spotlight@2x.png'],
    [(76, 76), 'icon_ipad.png'],
    [(152, 152), 'icon_ipad@2x.png']
]

icon_path = sys.argv[1]
output_path = sys.argv[2]

for size_class in size_classes:
    outfile = size_class[1]
    if icon_path != outfile:
        outfile = output_path + "/" + outfile
        try:
            im = Image.open(icon_path)
            im.thumbnail(size_class[0], Image.ANTIALIAS)
            im.save(outfile, "PNG")
        except IOError:
            print "cannot create icon for '%s'" % infile

