# System validation
Quantify the optical parameters of the phantoms and compare them with the previously quantified results.

---

## Prepare
* The measured data saved as below structure.
    └── 20240612
        ├── IRF_530  (530 is the laser intensity you used to measure the data. Using same intensity with different SDS and phantoms will be more convenient, just in case you need to use different intensity)
        │   ├── IRF1
        │   │   ├── IRF1_1.phu
        │   │   ├── IRF1_2.phu
        │   │   └── IRF1_3.phu
        │   ├── IRF2
        │   │   ├── IRF2_1.phu
        │   │   ├── IRF2_2.phu
        │   │   └── IRF2_3.phu
        └── phantom_2_530
            ├── SDS1
            │   ├── SDS1_1.phu
            │   ├── SDS1_2.phu
            │   └── SDS1_3.phu
            └── SDS2
                ├── SDS2_1.phu
                ├── SDS2_2.phu
                └── SDS2_3.phu

* The previously quantified OP results and the simulated DTOFs of the phantoms. Saved in `1_ph_info`.
* Use `2_1_phantom_simulation` to make the lookup table for accelerating the process of quantifting the OPs of phantoms.
---

## Steps

1. In `S1_read_phu.m`, set the folder path, the folder contains the data you want to process, and the number of times you repeated the measurements. This code will arrange the data and save `info_record.mat`, `TPSF_collect.mat` in each process folder. 
    
    ```matlab=12
    folderPath='20240612/IRF';
    process_folder={'IRF1','IRF2'};
    repeat_times=5;
    ```

2. In `S2_process_data.m` you should give the below information.
    ```matlab=22
    motherfolder='20240612';
    folderPath='IRF_530';
    folderNames={'IRF1','IRF2'};

    first_time_flag=0; % 1:first time processing the data (if you don't know where the starting point is, please set this to 1)
    start_point=105;   % if first_time_flag=0, please set the start point you want to use.

    for_IRF=1;
    do_any_plot=1;
    ```
    * first_time_flag: if you don't know where the starting point is, please set this to 1. The code will help you choose the start point later. 
    * start_point: if you already know the starting point, you can set it here and set the `first_time_flag` to zero.
    * for_IRF: if you are processing IRF data, please set this to one.
    
    The processed data will be saved in the `folderPath` you set. And the IRF processed data will be saved to corresponding phantom folder using same laser intensity.
    
3. Run `S3_0_compare_sim_with_exp.m` to compare the experimental data with the predicted value before actually quantifying OPs using the measured data. `S3_fitting.m` and `S3_1_plot_fitting_result.m` to fit the data and plot the result, 


4. T0 to T5 is used for system noise evaluation.
