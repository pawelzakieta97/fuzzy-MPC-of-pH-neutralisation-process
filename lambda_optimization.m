addpath('./membership_functions/');
op_points = [3, 5, 7, 8.5, 10];

D = 80;
N = D;
Nu = 5;
lambda_init = [0.01, 0.1, 0.1, 1, 0.1];
step_size = 0.1;
[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal);
params = ModelParams();



[lambdas_optimized, error] = fmincon(...
@(lambdas)evaluate_controller(lambdas, fc, false, 1, 0), lambda_init,...
-eye(length(lambda_init)), zeros(length(lambda_init),1));

% [lambdas_optimized, error] = ga(...
% @(lambdas)evaluate_controller(lambdas, fc, false, 1, 0), 5,...
% -eye(length(lambda_init)), zeros(length(lambda_init),1));
