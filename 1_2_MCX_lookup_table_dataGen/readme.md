# MCX lookup table data generate
Use the simulated lookup table to generate some spectrum or data for training ANN.  

---

## Prepare
* The pre-simulated lookup table.  

---

## Steps
0. Use `T1_smooth_data.m` to determine the best degree of polynomial function that fits the simulation data the most.  

1. In `S1_smooth_lookup_table.m`, set the mua range for generating ANN training data, and the program will generate some random combination in this range.  
    The mus range should be consistent with the mus you used to simulate the lookup table.  
    `num_random` is the number for random sets (for mua)
    
    If you want to use some optical parameters to generate some spectrum (to compare the reflectance from lookup table and MC simulation), you can set the `test_mode` not =0  
    ```matlab=36
    test_mode=0; % =0 to generate the whole training data; =1 or more to generate the result of lookup table using the testing parameters
    ```

2. You can plot the smooth result using `S1_1_plot_smooth_result.m`.
        
3. In `S2_do_interpolation.m`, set the mus range for generating ANN training data,
    The result will be in a [name + date] folder,  
    ![](https://i.imgur.com/7HzjD75.png)  
    
    If you use test mode, then there will be a file called `lkt_smooth_forward.txt`, which is the lookup table forward reflectance for your given OPs.

4. You can plot the interpolation results using `S2_1_interp_result_analysis.m`.

