# Spectrum Calibration
Use the simulation phantom spectra to calibrate the target spectra.  
[Link to HackMD](https://hackmd.io/@kaoben2731/BJllCVUBw)

---

## Prepare
* Your target spectra and phantom spectra
* The simulation spectra of the phantoms

---

## Calibration steps

1. Use `S1_1_choose_toUse_BG.m` to find which BG file to use.  
    
    The program will find the BG files in the folder, and plot the spectrum of them. You can see the figure and find whether there is any outlier:   
    ![](https://i.imgur.com/dnkUcDW.png)  
    If there is outlier, you can edit the array `ph_choose_index` in the matlab command window, then press `continue`; If there are no outlier, you can set `phokay` =1 in the command window, and press `continue`.
    After that, the program will save which BG you choose, and save the average BG spectrum of the chosen BGs.
    
2. Use `S1_2_extract_measured_spec.m` to turn the .mat files into .txt file.  
    The reason to use this program to turn .mat into .txt, is because when measure the spectrum there will be multiple shot for one SDS, so it should be average.  
    Also, the original data in .mat file is the intensity of each pixel, while the data we want to analysis is the intensity in each wavelength, so the program will do the job.  
    
    You should specify the folder containing the invivo measurement and the target name (including phantoms and subjects) of the spectrum. Also, the `num_of_phantoms` should match the number of phantom (not including subject) in `target_name_arr`, so the program can plot the figure properly.
    ```matlab=11
    input_dir='20201209_test_14'; % the folder of the experiment
    output_folder='extracted_spec'; % the folder of the extracted spectrum
    target_name_arr={'p1_1','p1_2','p1_3','p1_4','p1_5','p1_6','p1_7','p1_8','p2_1','p2_2','p3_1','p3_2','p4_1','p4_2','p5_1','p5_2','p6_1','p6_2','p6_3','tc_1','tc_2','tc_3','tc_4','tc_5','tc_6','tc_7','tc_8','tc_9','tc_10'};
    BG_name='bg';
    target_name_prefix='SDS_spec_arr_'; % the filename before the phantom name, notice that there sourld be a [target_name_prefix 'BG'] in the input_dir
    num_of_phantoms=19; % the former n targets are phantoms
    ```
    
    To let the program convert pixel into wavelength, some wavelenght calibration information should be given.
    ```matlab=18
    % about camera
    wavelength_boundary=[536.0026 1094.5]; % the min and max wavelength of the camera
    to_output_wl=[650 1070]; % the wavelength range to output spectrum, calculate CV or plot the figure
    camera_x_pixel=160;
    ```
    
    After the program is done, there will be a average specturm for each measurement, also a file to store the CV of the measurment.  
    ![](https://i.imgur.com/1FZzw7T.png)  
    The multiple shot will also be plot with the CV:  
    ![](https://i.imgur.com/liLRNdk.png)  
    There will also be a compare figure to compare all phantom spectra and subject spectra, and you can see if the target spectra are wrapped by the phantom spectra:  
    ![](https://i.imgur.com/4lGOBGp.png)  
    
3. Use `S1_3_choose_toUse_phantoms.m` to choose which phantom spectra to use.  
    As in `S1_1_choose_toUse_BG.m`, to prevent some phantom spectra be outlier, you should choose the proper index, and the program will save the average spectrm of each phantom.

4. Put the simulated phantom spectra in a folder.  
    ![](https://i.imgur.com/jPQoWdA.png)  
    Use `S2_1_get_calib_factor.m` to calculate the calibration factor in each wavelength.  
    The result (calibration factors) will be stored in the `output_folder_arr` folder under your measure folder.  
    ![](https://i.imgur.com/qNHUEdL.png)  
    And there will be a `figure` folder if you monitor the calibration, and the figures of simulated value v.s. measured value are in it, you can use this to check whether the relationship between measured value and simualted value are linear.  
    ![](https://i.imgur.com/YmCP3Cp.png)  
    
    You can use `S2_2_plot_calibration_effect.m` to plot the r^2 value and the calibrated phantom error for the calibration.  
    ![](https://i.imgur.com/5jdjgOC.png)  
    
5. Use `S3_calib_target_spec.m` to calibrate the target spectra.  
    The program will also plot the calibrated spectra:  
    ![](https://i.imgur.com/DVUVEaT.png)  
    
    You can also use `S4_compare_extracted_phantom_target.m` to compare the spectra of the targets and the phantoms:  
    Measured:  
    ![](https://i.imgur.com/0XGk758.png)  
    Simulated (calibrated):  
    ![](https://i.imgur.com/yAvTBss.png)
    
6. Use `S5_extract_calibrated_subject_spectrum.m` to calculate the average spectrum and the max/min spectrum and CV of the target.  
    You should select the index to use (not including the outliers), and specify the index in the program:  
    ```matlab=15
    to_use_index=[1:6]; % use these index of the calibrated spectrum
    ```

7. You can use `S6_compare_phantom_allSubjects.m` to compare the spectra of all phantoms and all calibrated targets.  
    Since the phantom spectra are simulated, and the target spectra are calibrated, they can be plot together and compare.
    ![](https://i.imgur.com/SIB1CsV.png)



---

## Analysis

1. You can use `S7_plot_subjectDeltaOD.m` to compare the in vivo spectrum delta OD and the absorption spectra of the hemoglobins.  
    ![](https://i.imgur.com/76uSeoy.png)  

2. You can use `S8_check_system_errorShift.m` to find the error shift the the system.  
    The input data should be the phantom spectra.  
    ![](https://i.imgur.com/ibBhwKw.png)  

3. You can use `S9_plot_subject_CV.m` to plot the subject CV.  
    ![](https://i.imgur.com/LZUuZWj.png)  
    Or use `S10_check_subject_errorShift.m` to find the error shift the the in vivo spectra.  
    ![](https://i.imgur.com/MWkUDyg.png)  

4. You can use `S11_cal_subject_spec_RMSPE.m` to calculate the target spectra RMSPE of the target.