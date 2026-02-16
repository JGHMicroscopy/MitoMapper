MitoMapper User Guide
Quick Start
1.	Download MitoMapper.zip and the MitoMapper.ijm file.
2.	The .zip file contains the complete data structure and all required subfolders.
3.	Drag and drop the MitoMapper.ijm file into Fiji to open it.
4.	Click the Run button.
A folder selection dialog will appear.
5.	Select the unzipped MitoMapper folder. You should now see all mask subfolders.
The program will automatically:
•	Loop through all images in the main folder
•	Load the corresponding annotation masks from the subfolders
•	Generate the graphical output
•	Save both the output images and the .txt results file in the Results folder
Image Naming Convention
Your image files must follow this naming format:
MainImageID_extension
Where the extension is one of the following:
•	_nucleus
•	_myo
•	_mito
•	_cell
The only optional mask in the base version of MitoMapper is the nucleolus mask.
