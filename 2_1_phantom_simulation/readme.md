# Phantom simulation
Simulate the phantom spectrum.
Create a lookup table to fit the experimental data of phantoms.
---

## Prepare
* The mus you want to simulate
* The g of the phantom

---

## Simulation steps

1. Make a folder for output, and put a `mus_to_sim.txt` in it.  
    ![](https://i.imgur.com/bh5J9sj.png)  
    Each row is a mus (1/cm) to simulate. The mus should cover all phantoms in all wavelengths. You can use `S0_plot_phantom_OPs.m` to plot the OPs of the phantoms, and decide the mus to simualte.  
    ![](https://i.imgur.com/391DO4I.png)

    Also, set the parameters of the system in a json file, e.g.,  `sim_setup_new_param.json`, you can refer to [MCML_GPU](https://github.com/kaoben2731/MCML_GPU) for how to setting.  
    ![](https://i.imgur.com/JPP2UcL.png)  

2. Set the parameter for simulation in `S1_MCML_sim_lkt.m`, including the g for the phantom, how many GPU you want to use. This program is capable of using different GPU in one computer, or using multiple GPUs simultaniously.  
    ```matlab=12
    output_dir='MCML_sim_lkt'; % the already exist output folder, which containing the mus to simuilate
    g=0;
    n=1.457;
    use_multiple_GPU=0; % =1 if you want to use multi-GPU to simulate
    GPU_available=[0 1 1 1 1]; % which GPU on the multi-GPU computer to use
    do_GPU_setting=0; % =1 if you don't use multi-GPU, and want to use certain GPU
    GPU_index=0; % the index of certain GPU to use, start from 0
    to_sim_index=1:70; % the index to simulate

    sim_setting_file='sim_setup_new_param.json';
    ```

3. run `S1_MCML_sim_lkt.m` to do the simulation.  
    There will be a `run_n` folder in the output folder for each mus you simulated.  
    ![](https://i.imgur.com/OBpcNZ6.png)

    
4. run `S2_process_sim_result.m` to provess simulation results.  
    There will be the following files in each mus's folder. `sim_PL_merge.mat` is the main result for simulation, containing the weight and pathlength for each detected photon.  
    ![](https://i.imgur.com/nnuSvKa.png)

5. Use `S3_cal_reflectance_all_at_once.m` to calculate the reflectance of each phantom  
    You should set which wavelength to output, and the path and files of the phantoms OPs.  
    ```matlab=19
    sim_wl=800; % the wavelength to output simulate spectrum

    param_dir='epsilon'; % the folder containing the OPs of phantoms
    using_mua_file='mua_FDA_cm.txt'; % the mua file for the phantoms
    using_mus_file='musp_cm.txt'; % the mus file for the phantoms
    ```
    
    The output file for each phantom contains the DTOFs of each SDS.  

