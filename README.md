FatFace
=======

Many different cameras and photo management solutions detect and tag faces in photos. Cloud-integrated scales are also becoming common. FatFace extracts the regions identified as faces and overlays the subjects weight onto each picture. These pictures are then stitched into a video file to show changes in facial appearance in chronological order or lightest to heaviest. Extensions have been made to overlay other data as well such as fat mass, diet, exercise or days since a particular food was ingested. 

FatFace helps individuals understand what factors affect their facial appearance. It serves to motivate the individual by helping them understand the cause and effect relationship between different factors and facial appearance.

Usage
=======
In a directory containing photo files named with the .jpg extension and containing xmp-mp region metadata, run fatface.bash. To overlay weight data, include a CSV export of Withings for each user you wish to overlay named with the space-stripped name of the user as it is tagged in the photos (e.g. BillSchuller.csv). 

Options
=======
Edit fatface.bash to adjust the weight units, font size and output resolution of the photos.


Status
=======
Features that have been implemented
1. Face region extraction - xmp-mp region support, tested with photos containing 2 faces. 
2. Extract the "Creation Date" from exif metadata of each photo and extract the exactly corresponding date from user.csv to obtain weight. If the exact date is not in the user.csv file, NULL will be overlayed.
3. Output a photo extract of each face region described in the input photos metadata in a standard size.
4. Overlay weight and date onto photo.

Features that need to be implemented
1. Better styling on overlay
2. Extract last known weight for photos that do not have an exact date match.
3. Video stitching.
4. Sparkline overlay option
