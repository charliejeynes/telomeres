Instructions

The script in the "Telomeres_github.m" file, compares a super resolution image of telomeres to its diffraction limited fluorescence image counterpart. It excludes all features on the super resolution image that do not overlap with the diffraction limited image

The resulting super resolution image is then binarised and the matlab function "regionprops" is used to measure the properties of the telomeres 

I have included an example diffraction limited image "seriesF_LED", and the superresolution counterpart image can be downloaded from 
https://www.dropbox.com/s/nah5m3m7jziddpr/seriesF_jittered_super_resolution.tif?dl=0 (the image was too large to upload to github)

Create a folder called "analysis" and save the Telomeres_github.m into this folder.  Within the "analysis" folder, vreate another folder called "24_5_2016", and save the images into this file. 

Run the matlab script. A series of images should pop up displaying the super res and LED image. Click continue when promted to do so. On completion, a boxplot will be produced displaying the equivalent diameters of the telomeres from the super resolution image

---------------------------------------------------

