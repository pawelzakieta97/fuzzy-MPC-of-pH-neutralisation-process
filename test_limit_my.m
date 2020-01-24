addpath('./membership_functions/');

op_points = [3, 4.6, 6.4, 8, 10];
op_points = [2.96, 4.76, 6.7, 8.19, 10]
% op_points = [3, 5, 7, 8.5, 10];
% op_points = [7];
D = 80;
N = D;
Nu = 40;
lambda_init = [0.1,0.1,0.1,0.1,0.1];
lambda_init = [1,1,1,1,1]*2;

step_size = 0.05;
sigmas = [0.3,0.5,0.3,0.5,0.3];
[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 1);
fc.numeric = false;
fc.set_sigmas(sigmas);
% fc.set_sigmas([1.1,0.38,1.2,0.43,1.53]);

fc.set_sigmas(sigmas);
fm.set_sigmas(sigmas);
fc.main_model.set_sigmas(sigmas);
fc.sim_model = WienerModel(1);
fc.numeric = 0;

Ysp = [5*ones(30,1); 8*ones(40,1); 4.5*ones(30,1)];
model_a = simulation(fc, Ysp,1);
model_a.plot();
%model_a.save_csv('../wykresy/ph/ograniczenia/a.csv');

fc.lim_use_sim_model = 0;
fc.limit_output = 1;
fc.limit_type = 1;
fc.lim_samples = 1;
fc.upper_bandwidth = 0.3;
fc.lower_bandwidth = 0.3;
fc.output_limit = [4.2, 8.3];
model_l = simulation(fc, Ysp, 1);
model_l.plot();

fc.lim_use_sim_model = 0;
fc.limit_output = 1;
fc.limit_type = 1;
fc.lim_samples = 1;
fc.upper_bandwidth = 1;
fc.lower_bandwidth = 1;
fc.output_limit = [4.2, 8.3];
model_l = simulation(fc, Ysp, 1);
model_l.plot();


Ysp = [7*ones(30,1); 8*ones(40,1); 4.5*ones(30,1)];
fc.limit_output = 0;
model_a = simulation(fc, Ysp,1);

model_a.plot();
%model_a.save_csv('../wykresy/ph/ograniczenia/a.csv');

fc.lim_use_sim_model = 0;
fc.limit_output = 1;
fc.limit_type = 1;
fc.lim_samples = 1;
fc.upper_bandwidth = 0.3;
fc.lower_bandwidth = 0.3;
fc.output_limit = [4.2, 8.3];
model_l2 = simulation(fc, Ysp, 1);
model_l2.plot();

fc.lim_use_sim_model = 0;
fc.limit_output = 1;
fc.limit_type = 1;
fc.lim_samples = 1;
fc.upper_bandwidth = 1;
fc.lower_bandwidth = 1;
fc.output_limit = [4.2, 8.3];
model_l2 = simulation(fc, Ysp, 1);
model_l2.plot();
