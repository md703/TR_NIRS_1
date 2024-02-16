# MRI Segmentation
Divide the MRI head model into different layers, and make it a voxel model.

---

## Prepare
* Your MRI files
* Install the following toolbox for MATLAB:
    1. SPM12
    2. Iso2Mesh
    3. Image Processing Toolbox
    4. Mesh2EEG
    5. (Optional) Parallel Computing Toolbox

---

## Segmentation steps

### There is also a video version on [YouTube](https://youtu.be/1v6GToNTDts).
{%youtube 1v6GToNTDts %}

1. Using SPM to segment model
    1. Type `spm` in the matlab command line to launch the SPM.  
    2. The menu of SPM will show up.  
    ![menu](https://i.imgur.com/M4yVsTA.png)
    3. Choose the `DICOM import`
    4. Use the file selector to select the MRI files   
    ![file_select](https://i.imgur.com/Co5qGNl.png)  
    If it is the structural image, there will be 192 images (according to our setting)  
    Choose the folder in the left hand side, then select the MRI slices on the right hand side, the selected files will appear in the down side.  
    5. Then set the parameters and run  
    ![dicom_import](https://i.imgur.com/sfGRkAD.png)  
    The run button is on the up left.  
    After running, there will be a new folder and a .nii file, which is the merged DICOM file.  
    ![import_result](https://i.imgur.com/I7u5Dn6.png)  
    6. Then use the `Coregister (Reslice)` tool to change the direciton and position of the MRI file.  
    ![coreg_reslice](https://i.imgur.com/5LGaswc.png)  
    The image defining space is a template MRI file.  
    And there will be a r*.nii file in the output folder.  
    ![coreg_result](https://i.imgur.com/oU4MRIa.png)  
    7. Then use the `Segment` tool to segment the file into differnet layers.  
    ![segment](https://i.imgur.com/Re32w3m.png)
    We only need to select the resliced to segment.  
    This step will take a little bit longer to run  
    ![](https://i.imgur.com/JWsdMey.png)  
    There will be 5 c*.nii files in the output folder, representing the probabilities for different tissues.  
    8. You can use the `Display` tool to see the MRI file.  
    ![](https://i.imgur.com/QSk6qwU.png)  
    And the if the orientation of the image is wierd, you can rotate the image using the parameters in the lower left side.  
    ![](https://i.imgur.com/X1M7gUg.png)  
    After setting the rotation parameters, click `Reorient` to save the rotated file.  
    You can also change the position of the origin using this method.  
    9. If the MRI file seems distorted to you, then you can use `Normalise(Est & Write)` to do spatial normalization.  
    ![](https://i.imgur.com/tFnPrgN.png)  
    Select the original image as the `Image to Align` and `Images to Write`.  Also remember to change the `Bounding box` to [-100 -130 -80;100 100 110] and the `Voxel sizes` according to the original value.  
    ![](https://i.imgur.com/UcCis6O.png)  
    After the normalize, there will be a file stert with **w** in the folder.  
    ![](https://i.imgur.com/AbB5n3m.png)  
    And the result seems more normal.  
    ![](https://i.imgur.com/QE3dvCY.png)  
    After check the orientation and shape of the image, you can go back to step 7 to do the segmentation.  
    
2. Use Matlab to process the segmented models
    1. (Optional) Open the `s0_preprocess_SPM_output.m`, and pre-process the SPM output automatically.  
    If you use this script, then there will be a `preprocess_maxIndex.mat` file in the subject's MIR folder.  
    ![](https://i.imgur.com/87kyxI1.png)
    
    2. Open the `s1_Segmentation_Protocol.mlx`, and change the folder to process.  
    ![protocal_input](https://i.imgur.com/8WWtw9n.png)  
    3. Run the script **section by section**.  
    Then there will be a segmented_tissue.nii in the folder.  
    ![protocal_result](https://i.imgur.com/Y9mCwct.png)  
    4. Open the `s2_segmented_to_mesh.m` to construct a mesh for the segmented model.  
    Also save the model into .mat file.  
    ![](https://i.imgur.com/HoH83Ck.png)  
    The surfce of head and the brain will be plot, and the circled file is the output file.  
    5. Open the `s3_find_fiducials.m` to select the position of 4 reference points on the head.  
    ![](https://i.imgur.com/C2zHSJu.png)  
    Changing the circled setting of the points.  
    The position for four points are shown below (The rad dot in D. should be the position for M1 and M2.)
    ![](https://i.imgur.com/m7RmMv6.png)

    6. Open the `s4_find_EEG_POS.m` to construct the EEG points map on the head surface.  
    ![](https://i.imgur.com/t6sj8U9.png)  
    The head model with EEG points will be plot, and the models will be saved in a `headModel*_EEG.mat` file.  
    Remember to change the setting in the script to match the segmentation settings:  
    ![](https://i.imgur.com/fXrkECo.png)  
    If there are some error while finding the EEG point on the model, this script will randomly change the position of the reference points, but if it retry too many times, you might try to increase the `random_change_size` or check the model in the previous steps.  
    ![](https://i.imgur.com/UR38Pem.png)

    
---

## Files
### s0_preprocess_SPM_output.m
Preprocess the SPM output, delete the noise outside the scalp.  
### s1_Segmentation_Protocol.mlx
The main script for segmentation.  Turn the 5 output of SPM into a single model.  
### s2_segmented_to_mesh.m
Make a mesh for the scalp surface and brain surface.  
### s3_find_fiducials.m
Find the reference points for finding EEG points.  
### s4_find_EEG_POS.m
Find the EEG points on the scalp, also save the model into a MATLAB `.mat` file for MC simulation.  
### fun_image_seg.m
Called by `s0_preprocess_SPM_output.m` and `s1_Segmentation_Protocol.mlx`, do the image region segmentation.  

---

## Reference
* Jurcak, Valer & Tsuzuki, Daisuke & Dan, Ippeita. (2007). 10/20, 10/10, and 10/5 systems revisited: Their validity as relative head-surface-based positioning systems. NeuroImage. 34. 1600-11. 10.1016/j.neuroimage.2006.09.024. 