addpath('./membership_functions/');

op_points = [3, 4.6, 6.4, 8, 10];
op_points = [2.96, 4.76, 6.7, 8.19, 10]
% op_points = [3, 5, 7, 8.5, 10];
% op_points = [7];
D = 80;
N = D;
Nu = 40;
lambda_init = [0.1, 0.2, 0.1, 0.2, 0.1];
step_size = 0.1;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 1);
fc.numeric = false;
fc.set_sigmas([1,1,1,1,1]);
% fc.set_sigmas([1.1,0.38,1.2,0.43,1.53]);

Ysp = [5*ones(50,1); 8*ones(50,1); 4.5*ones(100,1)];
model_a = simulation(fc, Ysp,1);
model_a.plot();

fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 1;
fc.output_limit = [4.3, 8.2];
model_al1 = simulation(fc, Ysp,1);
model_al1.plot();

fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 5;
fc.output_limit = [4.3, 8.2];
model_al5 = simulation(fc, Ysp,1);
model_al5.plot();