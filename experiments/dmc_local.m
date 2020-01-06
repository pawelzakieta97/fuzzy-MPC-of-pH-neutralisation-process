addpath('./membership_functions/');
addpath('../');
% op_points = [3, 4.6, 6.4, 8, 10];
% op_points = [2.96, 4.76, 6.7, 8.19, 10]
% op_points = [3, 5, 7, 8.5, 10];
op_points = [7];
D = 80;
N = D;
Nu = 5;
% lambda_init = [0.01, 1, 0.1, 1, 0.1];
% lambda_init = [0.1, 0.1, 0.1, 0.1, 0.1];
% lambda_init = [0.01, 0.1, 0.02, 1, 0.1];
lambda_init = [0.1];
%lambda_init = [0.1, 1, 0.2, 10, 1];
step_size = 0.1;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal);
% fc.numeric = false;
% fc.set_sigmas([1,1,1,1,1]);
% fc.set_sigmas([1.1,0.38,1.2,0.43,1.53]);

% Ysp = generate_setpoint();
% Ysp = (Ysp-mean(Ysp))/20+7;
Ysp = random_signal(90, 30, [6.7, 7.3], 1);
model_a = simulation(fc, Ysp);
model_a.plot();