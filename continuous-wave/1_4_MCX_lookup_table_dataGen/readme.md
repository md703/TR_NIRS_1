# MCX lookup table data generate
Use the simulated lookup table to generate some spectrum or data for training ANN.  

---

## Prepare
* The pre-simulated lookup table.
* The regression model that turn high NA into low NA
* The mua range for to generate the ANN training data, or the optical parameters to generate spectrum.  

---

## Generate steps

1. In `S1_main_generate_noMerge.m`, set the mua and mus range for generating ANN training data, and the program will generate some random combination in this range.  
    The mus range should be consistent with the mus you used to simulate the lookup table.  
    `num_random` is the number for random sets (for mua), for mus, the number of random set is the set number of original lookup table + `num_random`.  
    E.g., `num_random=3000`, and there are 2808 sets of mus in the original lookup table simulate, so there will be 3000X5808=17424000 sets of ANN training data.  
    ```matlab=19
    % about parameters
    mua_ub=[0.6 0.45 0.1   0.5]; % 1/cm
    mua_lb=[0.1 0.05 0.015 0.05]; % 1/cm
    mus_ub=[350 350 37 350]; % 1/cm
    mus_lb=[50 50 10 50]; % 1/cm

    % mua_ub=[0.6 0.45 0.1   0.7]; % 1/cm
    % mua_lb=[0.03 0.01 0.015 0.02]; % 1/cm
    % mus_ub=[350 350 37 410]; % 1/cm
    % mus_lb=[50 50 10 50]; % 1/cm

    % about random
    num_random=3000; % how many nuber to random, for mua.  For mus, it's this number + number of original lookup table set
    normal_cutoff=2; % if the random value is not in [-a a], than re-generate a random number
    ```
    
    The location of the simulated lookup table, also the regression model (High NA to low NA) should be assigned.
    ```matlab=12
    lookup_table_arr='/media/kaoben2731/TOSHIBA EXT/Ryzen_ubuntu_backup/20200106_MCX_lookup_table'; % the dir containing the unmerged lookup table
    ratio_model_dir=fullfile('..','20200328_MCX_invivo_reflectance_simulation','sim_2E10_n1457_diffNA_16','AIO_model_stepwise_9'); % the dir containing the highNA/lowNA regression model
    ```
    
    If you wnat to use some optical parameters to generate some spectrum (to compare the reflectance from lookup table and MC simulation), you can set the `test_mode` not =0  
    ```matlab=36
    test_mode=0; % =0 to generate the whole training data; =1 or more to generate the result of lookup table using the testing parameters
    ```
    
    And edit this part of the code to set the path to the optical parameters you want to use to generate testing spectrum.  
    ```matlab=101
    %% test
    if test_mode==1
        op=load('OPs_to_sim_6/toSim_OP_1.txt');
        mus_param_arr=op(:,2:2:8);
        mua_param_arr=op(:,1:2:8);
    elseif test_mode==2
        op=load('OPs_to_sim_11/toSim_OP_65.txt');
        mus_param_arr=op(:,2:2:8);
        mua_param_arr=op(:,1:2:8);
    elseif test_mode==3
        op=load('OPs_to_sim_11/toSim_OP_66.txt');
        mus_param_arr=op(:,2:2:8);
        mua_param_arr=op(:,1:2:8);
    end
    ```
        
2. Run `S1_main_generate_noMerge.m`.
    The result will be in a [name + date] folder,  
    ![](https://i.imgur.com/7HzjD75.png)  
    In each result folder, there will be 3 files,  
    ![](https://i.imgur.com/qlEFcAR.png)
    1. `param_range.txt` is the range of the OPs (mua, mus)
    2. `all_param_arr.mat` is the main result, containing the mua, mus for each layer, also the reflectance for each SDS.
    3. `lit_process_time.txt` is the cost time (in secs) to make this training data set.

    If you use test mode, then there will be a file called `lkt_smooth_forward.txt`, which is the lookup table forward reflectance for your given OPs.
