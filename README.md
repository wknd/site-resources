# site-resources


### images
to handle images properly, they need to be placed in the correct place
when passing an image to something that would display it, the image object has 2 parameters
> image:
>>   name: the_filename_of_the_image  
>>   global: [somevalue]

the value of global determines where the image is located
it can have one of the following values
* global: image resides in the main projects-assets ```assets/images/global/```
* project: image resides in the sub projects-assets ```assets/images/global/```
* collection: image resides in the sub-projects assets ```assets/images/collections/[collectionName]/```
* local: image resides in the sub-projects assets if it is a post it is in ```assets/images/posts/YYYY-MM-DD-post-title``` if it is a page part of a collection its location is ```assets/images/collections/[collectionName]/pageTitle/```

if global is false or not set, it defaults to ```local```.
if global is set to true, it defaults to ```global```.

each corresponding ```assets/images/``` directory should also have a corresponding ```assets/images-original/``` directory.

#### minify images

I'm using the default imagemagick stuff in ubuntu and standard gnu find. Other than that there is no dependencies for this little image processing script.
In case you don't have it already
```
sudo apt-get install image-magick
```
That should provide the ```convert``` binary.

When you add new images you should run the ``` minifyimages.sh``` script. The script will take all the images in the ```../assets/images-original/``` folder, 
minify them and put them in the ```../assets/images/``` folder if they don't already exist. It will also create the required subdirectories as needed.
This could possibly be further automated with some git hooks but that is a bit of a pain.

This script also generates the images at different resolutions (a normal resized one for use in articles, and one that is resized and cropped to a height of 600px high for use in index pages), however the images are not guaranteed to be that lower resolution! If the resized image has a larger filesize than one resized at a larger size, the script will instead symlink to that smaller file which has a larger resolution.
