addpath('./membership_functions/');
addpath('../');

op_points = [3, 4.6, 6.4, 8, 10];
op_points = [2.96, 4.76, 6.7, 8.19, 10];
D = 80;
N = D;
Nu = 40;
lambda_init = [0.1, 0.2, 0.1, 0.2, 0.1];
lambda_init = [10, 10, 10, 10, 10];
step_size = 0.1;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 1);
fc.numeric = false;
fc.set_sigmas([0.6,0.6,0.6,0.6,0.6]);
fm.set_sigmas([0.6,0.6,0.6,0.6,0.6]);
%fm.set_sigmas([1.1,0.38,1.2,0.43,1.53]);
Ysp = generate_setpoint();
model_a = simulation(fc, Ysp,1);
model_a.plot();
%model_a.save_csv('../wykresy/ph/an10.csv');

fc.update_lambdas([1, 0.5, 1, 0.2, 1]);
model_a2 = simulation(fc, Ysp,1);
model_a2.plot();
%model_a2.save_csv('../wykresy/ph/an02.csv')