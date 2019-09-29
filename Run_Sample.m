% This code shows how to run a Nuclear-Norm Regularized Regression problem using our cache-optimized ADMM solver

% Add directories for
% 1. Solver
addpath 'ADMM/'
% 2. Loss proximal operators
addpath 'ADMM/Losses/'
% 3. Regularization proximal operators
addpath 'ADMM/Regularizers/'

% ###### Please insert code to load
% ######   1. feature matrix X
% ######   2. labels Y
% ######   3. task_indices
% ######   4. cell array FoldIds whose entries each specify the foldID argument
% ###### as specified in manual for the ADMMCV function

% Number of tasks T
T = length(Y);
% Loss arguments to scale feature matrix columns by standard deviation
% and to treat tasks individually (please see manual)
init_loss_args = {'xscale', 'Std', 'yscale', 'none', 'groups', {1:T}};
init_reg_args = [];

%Determines regularization parameter sequence to solve for
fprintf('Finding lambdas\n');
[ lambdas ] = nuclear_lambda( X, Y, task_indices, init_loss_args );

%Perform cross validation
fprintf('Starting Cross Validation\n');
for i = 1 : length(FoldIds)
[ predicted, foldID ] = ADMMCV(FoldIds{i}, 'random', 10, X, Y, task_indices, lambdas, ...
    @init_regression, @init_nuclear, ... %Loss initialization
    @prox_regression, @prox_nuclear, ... %Prox operators
    init_loss_args, init_reg_args, ... %Loss/Reg arguments
    @finalize_regression, true); %Additional parameters

% Save predictions
save(['pred', num2str(i), '.mat'], 'predicted');
end