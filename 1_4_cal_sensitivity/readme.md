# Calculate sensitivity
Calculate the sensitivity of each SDS and each gate.

---

## Prepare
* The ANN models you trained at the previous step.
---

## Steps

1. In `S1_individual_gate.m`, set the baseline optical parameters and the change rate to exam. This code will get the results of reflectance change, sensitivity, and sensitivity ratio.
    
    ```matlab=12
    baseline=[0.15 0.15 0.2 120 75 125];
    changerate_to_exam=[-20 -10 10 20];
    subject_name_arr={'KB','ZJ','WH'}; % 'KB','CT','BY'
    ```