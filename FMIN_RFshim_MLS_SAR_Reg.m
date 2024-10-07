function [rfDrives, relError, errorCost] = FMIN_RFshim_MLS_SAR_Reg(b1Field, roiMask, VOP, lambda)

% Dimensions of the input B1 field
[Nx, Ny, Nz, Nc] = size(b1Field);

% Create a logical mask and calculate the number of nonzero voxels
roiMask = logical(roiMask);
maskRep = repmat(roiMask, [1, 1, 1, Nc]);
maskIdx = find(maskRep);
N = numel(maskIdx) / Nc;

% Extract the S matrix from the B1 field
A = double(reshape(b1Field(maskIdx), [N, Nc])).';

% Prepare the target profile (targetProfile)
targetProfile = double(roiMask(roiMask));
b = targetProfile(:).';

% Set up the initial solution for fmincon as twice the length of A
% for both real and imaginary components
x = double([ones(size(A, 1), 1); 2*pi*rand(size(A, 1), 1)]).';

% Define the objective function for fmincon
fun = @(x) norm(abs((x(1:size(A, 1)) + 1i*x(size(A, 1)+1:end)) * A) - b)^2 + lambda .* max(cellfun(@(xvar)abs((x(1:size(A, 1)) + 1i*x(size(A, 1)+1:end))*xvar*(x(1:size(A, 1)) + 1i*x(size(A, 1)+1:end))'),VOP));

% Define constraints for fmincon (empty in this case)
Aeq = [];
beq = [];
Aineq = [];
bineq = [];
lb = [];
ub = [];

% Define the options for fmincon
options = optimoptions('fmincon','Algorithm','interior-point');

% Call fmincon function to minimize the objective function
x = fmincon(fun, x, Aineq, bineq, Aeq, beq, lb, ub, [], options);

% Calculate the error cost and the relative error of the solution
rfDrives = x(1:size(A, 1)) + 1i*x(size(A, 1)+1:end);
relError = norm(abs(rfDrives * A) - b)./norm(b);
errorCost = fun(x);

% Return the optimized RF drives
end
