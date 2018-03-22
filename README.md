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
