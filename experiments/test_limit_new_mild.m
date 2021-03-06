addpath('./membership_functions/');

op_points = [3, 4.6, 6.4, 8, 10];
op_points = [2.96, 4.76, 6.7, 8.19, 10]
% op_points = [3, 5, 7, 8.5, 10];
% op_points = [7];
D = 80;
N = D;
Nu = 40;
%lambda_init = [0.5,0.5,0.5,0.5,0.5];
lambda_init = [1,1,1,1,1];

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
fc.main_model = WienerModel(1);
fc.dmc_disturbance = 1;
fc.numeric = 0;

Ysp = [5*ones(30,1); 8*ones(40,1); 4.5*ones(50,1)];
Ysp = [7*ones(10,1); 8*ones(20,1); 6.5*ones(20,1); 8*ones(20,1)];
model_a = simulation(fc, Ysp,1);
model_a.plot();
model_a.save_csv('../wykresy/ph/ograniczenia/a_simple.csv');

fc.lim_use_sim_model = 0;
fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 1;
fc.output_limit = [4.2, 8.3];

model_al1 = simulation(fc, Ysp,1);
model_al1.plot();
model_al1.save_csv('../wykresy/ph/ograniczenia/a1_simple.csv');

fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 2;
fc.lim_use_sim_model = 0;
fc.output_limit = [4.2, 8.3];
model_al5 = simulation(fc, Ysp,1);
model_al5.plot();
model_al5.save_csv('../wykresy/ph/ograniczenia/a2_simple.csv');

fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 5;
fc.lim_use_sim_model = 0;
fc.output_limit = [4.2, 8.3];
model_al10 = simulation(fc, Ysp,1);
model_al10.plot();
model_al10.save_csv('../wykresy/ph/ograniczenia/a5_simple.csv');



fc.linearize_sim_model = 1;
fc.lim_use_sim_model = 1;
fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 1;
model_wl1 = simulation(fc, Ysp,1);
model_wl1.plot();
model_wl1.save_csv('../wykresy/ph/ograniczenia/w1_simple.csv');

fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 2;
fc.lim_use_sim_model = 1;
model_wl5 = simulation(fc, Ysp,1);
model_wl5.plot();
model_wl5.save_csv('../wykresy/ph/ograniczenia/w2_simple.csv');

fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 5;
fc.lim_use_sim_model = 1;
model_wl10 = simulation(fc, Ysp,1);
model_wl10.plot();
model_wl10.save_csv('../wykresy/ph/ograniczenia/w5_simple.csv');


fc.multi_lin = 1;
fc.linearize_sim_model = 1;
fc.lim_use_sim_model = 1;
fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 1;
model_wl1 = simulation(fc, Ysp,1);
model_wl1.plot();
model_wl1.save_csv('../wykresy/ph/ograniczenia/wmulti1_simple.csv');

fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 2;
fc.lim_use_sim_model = 1;
model_wl5 = simulation(fc, Ysp,1);
model_wl5.plot();
model_wl5.save_csv('../wykresy/ph/ograniczenia/wmulti2_simple.csv');

fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 5;
fc.lim_use_sim_model = 1;
model_wl10 = simulation(fc, Ysp,1);
model_wl10.plot();
model_wl10.save_csv('../wykresy/ph/ograniczenia/wmulti5_simple.csv');
