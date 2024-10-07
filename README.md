# MLSOptimisationCodeSAR
README: B1 Field Optimization with SAR Regularization

Overview:  
This MATLAB script performs optimization on B1 fields using an iterative process to minimize local SAR while maintaining low root mean squared error (RMMSE). The user can select B1 field data, brain mask, and VOP (Virtual Observation Points) files to perform the optimization. The script generates an L-curve plot showing the trade-off between local SAR and RMMSE.

Requirements:  
  - MATLAB installed with the following toolboxes:
    - Optimization Toolbox
    - Image Processing Toolbox (if needed for further mask operations)
  - Required input files to load:
    - `B1_3D_FullHead.mat` – Contains the B1 field data of the selected .
    - `Brain_Mask_DBSFullCoverage.mat` – Contains the brain mask for region selection.
    - `VOPs.mat` – Contains the VOPs (Virtual Observation Points) data.

Usage Instructions:  
 1. Load Input Files:  
    Upon running the script, users will be prompted to select the following files:
    - B1 Field Data: A `.mat` file containing the B1 field map of specific coil (e.g., `B1_3D_FullHead.mat`).
    - Brain Mask: A `.mat` file with the brain mask of Duke or Billie (e.g., `Brain_Mask_DBSFullCoverage.mat`).
    - VOPs Data: A `.mat` file containing the VOPs matrix of specific coil with or without DBS (e.g., `VOPs.mat`).

  2. Running the Code:  
    - Downsampling Factor: The script resizes the B1 field and mask using a downsampling factor. By default, this is set to `5`. Modify this variable if needed.
    - Lambda Range: The script will iterate through a range of `lambda` values, which control the balance between RMMSE and SAR. The lambda values can be adjusted in the array at the start of the script.
    - Iterations: The optimization runs multiple times (default: `100`) for each lambda to find the best solution. You can change the number of iterations by modifying `it_multirun`.

  - **3. Output Files**:  
    The following outputs are generated and saved in the structure `OPOutput`:
    - `drives_Last`: Optimized drive weights for each lambda.
    - `errors_Last`: The RMMSE for each lambda.
    - `max_SAR`: Maximum local SAR for each lambda.

  4. L-Curve Plot:  
    The L-curve plot shows the trade-off between RMMSE and local SAR, helping users select the optimal lambda. The plot is automatically generated at the end of the script. 

  5. Customization:  
    - DownSamplingFactor: Adjust the resolution of B1 and mask maps.
    - Lambda values: Modify the `lambda` array to explore different regularization strengths.
    - Iteration count: Change `it_multirun` to increase or decrease the number of runs for each lambda value.

- **Troubleshooting**:  
  - Ensure all selected input files are in the `.mat` format and contain the expected variables (`B1_3D_FullHead`, `Brain_Mask_DBSFullCoverage`, and `Q_12_5` for VOPs).
  - If the script crashes, verify that the dimensions of the B1 field, mask, and VOPs are compatible.

Post Processing:
After visualizing the L-curves, select the desired point on the curve. The corresponding drive from the optimization can be used to:
Apply the optimized drive to the VOPs and B1 fields 
 			Observe the shimmed transmit field maps.
 			Compute the VOP-estimated 1-gram averaged SAR to evaluate local SAR for the selected configurastion.
