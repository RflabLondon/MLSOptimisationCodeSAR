% Overview:  
% This MATLAB script performs optimization on B1 fields using an iterative process to minimize local SAR while maintaining low root mean squared error (RMMSE). The user can select B1 field data, brain mask, and VOP (Virtual Observation Points) files to perform the optimization. The script generates an L-curve plot showing the trade-off between local SAR and RMMSE.
% 
% Requirements:  
%   - MATLAB installed with the following toolboxes:
%     - Optimization Toolbox
%     - Image Processing Toolbox (if needed for further mask operations)
%   - Required input files to load:
%     - `B1_3D_FullHead.mat` – Contains the B1 field data of the selected .
%     - `Brain_Mask_DBSFullCoverage.mat` – Contains the brain mask for region selection.
%     - `VOPs.mat` – Contains the VOPs (Virtual Observation Points) data.
%
%% Load the data

% Allow the user to select the DataLoad file
[FileName,PathName] = uigetfile('*.mat','Select the B1 DataLoad file');
if isequal(FileName,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(PathName, FileName)])
   DataLoad = load(fullfile(PathName, FileName));
end

% Allow the user to select the Brain Mask file
[FileName,PathName] = uigetfile('*.mat','Select the Brain Mask file');
if isequal(FileName,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(PathName, FileName)])
   mask_Original = load(fullfile(PathName, FileName));
   mask_Original = mask_Original.Brain_Mask_DBSFullCoverage; % Access the mask variable if needed
end

% Allow the user to select the VOPs file (Q_12_5)
[FileName,PathName] = uigetfile('*.mat','Select the VOPs file');
if isequal(FileName,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(PathName, FileName)])
   VOPsData = load(fullfile(PathName, FileName));
   Q_12_5 = VOPsData.Q_12_5; % Access the VOPs variable
end

%%

% Insert the B1 field and the corresponding mask as well as VOPs

B1_Original  = DataLoad.B1_3D_FullHead;
mask_Original = Brain_Mask_DBSFullCoverage;

[SzX, SzY, SzZ SzQ] = size(B1_Original);%2D

% Select the downsampling factor
DownSamplingFactor = 3; 

%Resizing the B1 maps
B1_resized = B1_Original(1 : DownSamplingFactor : SzX, 1 : DownSamplingFactor : SzY, 1 : DownSamplingFactor : SzZ, :); %3D
mask_resized = mask_Original(1 : DownSamplingFactor : SzX, 1 : DownSamplingFactor : SzY, 1 : DownSamplingFactor : SzZ); %3D

% Insert lambda range
lambda = [0.05, 0.5:2:20, 30:10:100, 200:100:1000, 10000];

% Get dimensions of B1 field
[SzX, SzY, SzZ, SzQ] = size(B1_resized);

% Initialize result matrices
drives_Last = zeros(SzQ, length(lambda));
errors_Last = zeros(1, length(lambda));
TolCost_Last = zeros(1, length(lambda));

% Iteration settings
it_multirun = 50;

% Iterate through lambda values
for k = 1:length(lambda)

    TolCost = 100000;

    % Perform multiple runs for each lambda
    for jj = 1:it_multirun
        [drives, errors, error_Cost] = FMIN_RFshim_MLS_SAR_Reg(B1_resized, mask_resized, Q_12_5, lambda(k));

        if error_Cost < TolCost
            w_shim_Optim = drives;
            errors_Optim = errors;
            TolCost = error_Cost;
        end
    end

    % Store the optimal results for each lambda
    drives_Last(:, k) = w_shim_Optim;
    errors_Last(k) = errors_Optim;
    TolCost_Last(k) = TolCost;

    disp(['Iteration ' num2str(k)])
end

% Initialize power and max_SAR arrays
power = zeros(1, length(lambda));
max_SAR = zeros(1, length(lambda));

% Calculate power and maximum SAR
for k = 1:length(lambda)

    drives_tmp = squeeze(drives_Last(:, k)).';

    % Calculating maximum SAR using VOPs
    SARdistributionShimmed = cellfun(@(xvar) abs(drives_tmp * xvar * drives_tmp'), Q_12_5);
    max_SAR(k) = max(SARdistributionShimmed);  % B1 maps are not normalized to 1W total

    % Calculate Power
    power(k) = (norm(drives_tmp))^2;
end

% Save results
OPOutput.drives_Last = drives_Last;
OPOutput.errors_Last = reshape(errors_Last, [length(lambda), 1]);
OPOutput.max_SAR = reshape(max_SAR, [length(lambda), 1]);

% Plot L-curve
figure
plot(OPOutput.max_SAR, OPOutput.errors_Last, 'o--r', 'LineWidth', 2)
hold on
ylabel('RMMSE')
xlabel('Local SAR')
xlim([0 10]); ylim([0 0.2]);

