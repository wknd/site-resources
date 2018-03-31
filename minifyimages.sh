#!/bin/bash
# follows advice from https://www.smashingmagazine.com/2015/06/efficient-image-resizing-with-imagemagick/ 
# to optimize the images
# but added -strip and -sampling-factor 4:2:0 and no posterize bullcrap and no thumbnail (though maybe thumbnail when I actually resize things)
# somehow it isn't always as good as what I first used..
# which was just 'convert image.jpg -sampling-factor 4:2:0 -strip -quality 80 output.jpg'
# this script was also checked on https://www.shellcheck.net/ and probably works on any system

# TODO: create different sized images once I support that sort of thing
# now uses convert instead of mogrify, though that means we can't turn off jpg fancy upsamplign cuz of some bug



SEARCHDIR="/../assets/images-original/" # location of the input images
OUTPUTDIR="/../assets/images/" # location of the output images
# use below for testing
#SEARCHDIR="/../wknd.github.io/assets/images-original/" # location of the input images
#OUTPUTDIR="/../test/" # location of the output images

SEARCHDIR=$(dirname "$0")$SEARCHDIR # make it relative to script location
OUTPUTDIR=$(dirname "$0")$OUTPUTDIR # make it relative to script location

WIDTHS=( 'original' 320 480 800 1200 1600 )
WIDTHMARGIN=50 # margin of error in pixels
HEIGHTMARGIN=25
# if image new width is in original size +- margin size then don't bother resizing
MAXHEIGHT=400
MAXWIDTH=1500
# images used to display posts need to not only match a certain width, but also get cropped
# HEIGHT is the max height the images are displayed at
# MAXWIDTH is the max width images would have if displayed
# these two parameters are used for cropped images, not the other resized ones

LOGO="logo.png"
# no different sizes for logo, and also more simple conversion which somehow leads to smaller size

echo minifying images in "$SEARCHDIR" and placing in "$OUTPUTDIR"

FILES=$(find "$SEARCHDIR" -type f -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg')
for f in $FILES; do
    OUTFILE=$OUTPUTDIR${f#$SEARCHDIR}
    OUTDIRECTORY=$(dirname "$OUTFILE")/
    OUTNAME=${OUTFILE%.*}
    OUTEXT=${OUTFILE##*.}
    INDIRECTORY=$(dirname "$f")/
    INNAME=${f%.*}
    INEXT=${f##*.}
    FILEWIDTH=$(identify -format "%w" "$f")
    FILEHEIGHT=$(identify -format "%h" "$f")
    #echo ""
    #echo "$FILEWIDTH"
    #echo "input file: $f"
    #echo "input dir : $INDIRECTORY"
    #echo "input name: $INNAME"
    #echo "input ext : $INEXT"
    #echo "output file: $OUTFILE"
    #echo "output dir : $OUTDIRECTORY"
    #echo "output name: $OUTNAME"
    #echo "output ext : $OUTEXT"
    if [ ! -d "$OUTDIRECTORY" ]; then
        # create directory in output dir if it doesn't exist already
        mkdir -p "$OUTDIRECTORY"
    fi
    
    
    heightplusmargin=$((HEIGHTMARGIN + MAXHEIGHT))
    # create smaller images too
    for width in "${WIDTHS[@]}"
    do
        widthupperbound=$((FILEWIDTH + WIDTMARGIN))
        widthlowerbound=$((FILEWIDTH - WIDTHMARGIN))
        heightupperbound=$((FILEHEIGHT + HEIGHTMARGIN))
        heightlowerbound=$((FILEHEIGHT - HEIGHTMARGIN))
        widthplusmargin=$((WIDTHMARGIN + width))
        #echo ""
        #echo "upper: $upperbound"
        #echo "lower: $lowerbound"
        #echo "old width: $FILEWIDTH"
        #echo "new width: $width"
        if [ "$width" = "original" ]; then
                NEWNAME="$OUTFILE"
                unset RESIZE
                unset CROP
                unset CROPRESIZE
              
                #echo "original"
        else
            DELTAHEIGHT=$((FILEHEIGHT - MAXHEIGHT))
            DELTAWIDTH=$((FILEWIDTH - width))
            #echo ""
            #echo "$f"
            #echo "original: $FILEWIDTH x $FILEHEIGHT"
            #echo "$width"
            #echo "w: $DELTAWIDTH"
            #echo "h: $DELTAHEIGHT"
            
            if [ "$DELTAWIDTH" -gt "$DELTAHEIGHT" ]; then
              # WIDTH needs more changing than height, rescale image based on height then crop to width
            
              if [ "$MAXHEIGHT" -gt "$heightlowerbound" ] && [ "$MAXHEIGHT" -lt "$heightupperbound" ]; then
                  # new height is within margin, don't change shit
                  CROPNAME="$OUTNAME-cropped-$width.$OUTEXT"                
                  unset CROPRESIZE
                  #echo "in bounds height"
              else
                  # new width is outside of margin, change its size
                  CROPNAME="$OUTNAME-cropped-$width.$OUTEXT"
                  CROPRESIZE=( -thumbnail "x$heightplusmargin"\> )
                  #echo "resize height"
              fi
              CROP=( -gravity Center -crop "$widthplusmargin"x+0+0 +repage )
            else
              # HEIGHT needs more changing than width, rescale based on width and maybe don't crop
              if [ "$width" -gt "$widthlowerbound" ] && [ "$width" -lt "$widthupperbound" ]; then
                  # new width is within margin, don't change shit
                  CROPNAME="$OUTNAME-cropped-$width.$OUTEXT"                
                  unset CROPRESIZE
                  #echo "in bounds width"
              else
                  # new width is outside of margin, change its size
                  CROPNAME="$OUTNAME-cropped-$width.$OUTEXT"
                  CROPRESIZE=( -thumbnail "$width"\> )
                  #echo "resize width"
              fi
              CROP=( -gravity Center -crop x"$heightplusmargin"+0+0 +repage )
            fi
            if [ "$width" -gt "$widthlowerbound" ] && [ "$width" -lt "$widthupperbound" ]; then
                # new width is within margin, don't change shit
                NEWNAME="$OUTNAME-$width.$OUTEXT"                
                unset RESIZE
                #echo "in bounds"
            else
                # new width is outside of margin, change its size
                NEWNAME="$OUTNAME-$width.$OUTEXT"
                RESIZE=( -thumbnail "$width"\> )
                #echo "resize"
            fi
        fi
        # for resized images
        if [ "$1" = "flush" ] || [ "$1" = "rebuild" ] || [ "$1" = "force" ] || [ ! -f "$NEWNAME" ]; then
          if [ "$OUTFILE" != "$OUTPUTDIR${LOGO#$SEARCHDIR}" ]; then
            # don't resize logo to weirdo widths
            convert "$f" -strip -sampling-factor 4:2:0 -filter Triangle -define filter:support=2 "${RESIZE[@]}" -unsharp 0.25x0.08+8.3+0.045 -dither None -quality 82 -define jpeg:fancy-upsampling=off -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none -colorspace sRGB "$NEWNAME"
            echo minified file "$NEWNAME"
          elif [ "$width" = "original" ]; then
            # don't resize for original or logo
            convert "$f" -strip -sampling-factor 4:2:0 -quality 80 -dither None "$OUTFILE"
            echo "converting logo $OUTPUTDIR${LOGO#$SEARCHDIR}"
          fi
        fi
        # for cropped images
        if [ "$1" = "flush" ] || [ "$1" = "rebuild" ] || [ "$1" = "force" ] || [ ! -f "$CROPNAME" ]; then
          if [ "$OUTFILE" != "$OUTPUTDIR${LOGO#$SEARCHDIR}" ] && [ "$width" != "original" ]; then
            # if its not a logo and not in original resolution, do the magic
            convert "$f" -strip -sampling-factor 4:2:0 -filter Triangle -define filter:support=2 "${CROPRESIZE[@]}" -unsharp 0.25x0.25+8+0.065 -dither None -quality 82 -define jpeg:fancy-upsampling=off -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none -colorspace sRGB "${CROP[@]}" "$CROPNAME"
            echo minified and cropped file "$CROPNAME"
          fi
        fi
    done

done
