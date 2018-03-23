#!/bin/bash
# follows advice from https://www.smashingmagazine.com/2015/06/efficient-image-resizing-with-imagemagick/ 
# to optimize the images
# but added -strip and -sampling-factor 4:2:0 and no posterize bullcrap and no thumbnail (though maybe thumbnail when I actually resize things)
# somehow it isn't always as good as what I first used..
# which was just 'convert image.jpg -sampling-factor 4:2:0 -strip -quality 80 output.jpg'
# this script was also checked on https://www.shellcheck.net/ and probably works on any system

# TODO: create different sized images once I support that sort of thing

SEARCHDIR="../assets/images-original/" # location of the input images
OUTPUTDIR="../assets/images/" # location of the output images

SEARCHDIR=$(dirname "$0")$SEARCHDIR # make it relative to script location
OUTPUTDIR=$(dirname "$0")$OUTPUTDIR # make it relative to script location

echo minifying images in "$SEARCHDIR" and placing in "$OUTPUTDIR"

FILES=$(find "$SEARCHDIR" -type f -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg')
for f in $FILES; do
    FILE=$OUTPUTDIR${f#$SEARCHDIR}
    DIRECTORY=$(dirname "$FILE")/
    if [ ! -d "$DIRECTORY" ]; then
        # create directory in output dir if it doesn't exist already
        mkdir -p "$DIRECTORY"
    fi
    if [ "$1" = "flush" ] || [ "$1" = "rebuild" ] || [ "$1" = "force" ]; then
        #force a recode of all the images
        mogrify -path "$DIRECTORY" -strip -sampling-factor 4:2:0 -filter Triangle -define filter:support=2 -unsharp 0.25x0.08+8.3+0.045 -dither None -quality 82 -define jpeg:fancy-upsampling=off -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none -colorspace sRGB "$f"
        echo force minified file "$FILE"
    elif [ ! -f "$FILE" ]; then
        # only recode the image if it doesn't exist already
        mogrify -path "$DIRECTORY" -strip -sampling-factor 4:2:0 -filter Triangle -define filter:support=2 -unsharp 0.25x0.08+8.3+0.045 -dither None -quality 82 -define jpeg:fancy-upsampling=off -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none -colorspace sRGB "$f"
        echo minified file "$FILE"
    fi
done
