addpath('../membership_functions/');
addpath('../');

op_points = [3, 4.6, 6.4, 8, 10];
op_points = [2.96, 4.76, 6.7, 8.19, 10];
D = 80;
N = D;
Nu = 40;
lambda_init = [0.1, 1, 0.05, 0.1, 0.1];
lambda_init = [0.2, 0.5, 0.1, 0.1, 0.1];
lambda_init = [0.1, 1, 0.1, 1, 0.1];
step_size = 0.05;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 1);
fc.numeric = false;
fc.set_sigmas([0.6,0.6,0.6,0.6,0.6]);
fm.set_sigmas([0.6,0.6,0.6,0.6,0.6]);
fc.update_lambdas([1, 0.5, 1, 0.2, 1]);
fc.main_model.set_sigmas([0.6,0.6,0.6,0.6,0.6]);

fc.set_include_disturbance(0);
Ysp = [4.5*ones(100,1)];
params = ModelParams();
u_nominal = repmat(params.u_nominal, [100,1]);
u_nominal(50:100,2) = u_nominal(50:100,2)*0.8;
model_a = simulation(fc, Ysp,1, u_nominal, params);
model_a.save_csv('../wykresy/ph/disturbance/nd.csv', [40,100]);
model_a.plot();

fc.reset();
fc.set_include_disturbance(1);
params = ModelParams();
model_ad = simulation(fc, Ysp,1, u_nominal, params);
model_ad.save_csv('../wykresy/ph/disturbance/d.csv', [40,100]);
model_ad.plot();

% OGRANICZENIA


fc.dmc_disturbance = 1;
fc.set_include_disturbance(0);
fc.linearize_sim_model = 1;
fm.set_sigmas([0.5,1,0.5,1,0.5]);
fc.sim_model = WienerModel(1);
fc.main_model = WienerModel(1);
fc.lim_use_sim_model = 0;
fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 5;
fc.output_limit = [4.4, 8.1];

model_andl = simulation(fc, Ysp,1, u_nominal, params);
model_andl.save_csv('../wykresy/ph/disturbance/ndl.csv', [40,100]);
model_andl.plot();

fc.dmc_disturbance = 1;
fc.set_include_disturbance(0);
fc.linearize_sim_model = 1;
fm.set_sigmas([0.5,1,0.5,1,0.5]);
fc.sim_model = WienerModel(1);
fc.main_model = WienerModel(1);
fc.lim_use_sim_model = 0;
fc.limit_output = 1;
fc.limit_type = 1;
fc.lim_samples = 5;
fc.output_limit = [4.4, 8.1];

model_andl = simulation(fc, Ysp,1, u_nominal, params);
model_andl.save_csv('../wykresy/ph/disturbance/ndl_my.csv', [40,100]);
model_andl.plot();


fc.dmc_disturbance = 1;
fc.set_include_disturbance(1);
fc.linearize_sim_model = 1;
fm.set_sigmas([0.5,1,0.5,1,0.5]);
fc.sim_model = fm;
fc.main_model = WienerModel(1);
fc.lim_use_sim_model = 0;
fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 5;
fc.output_limit = [4.4, 8.1];

model_adl = simulation(fc, Ysp,1, u_nominal, params);
model_adl.save_csv('../wykresy/ph/disturbance/dl.csv', [40,100]);
model_adl.plot();


fc.dmc_disturbance = 1;
%fc.set_include_disturbance(1);
%fc.sim_model = WienerModel(1);
fc.main_model = WienerModel(1);
fc.lim_use_sim_model = 1;
fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 2;
fc.output_limit = [4.4, 8.1];

model_adlwm = simulation(fc, Ysp,1, u_nominal, params);
model_adlwm.save_csv('../wykresy/ph/disturbance/dln.csv', [40,100]);
model_adlwm.plot();

fc.dmc_disturbance = 1;
%fc.set_include_disturbance(1);
%fc.sim_model = WienerModel(1);
fc.main_model = WienerModel(1);
fc.lower_bandwidth = 0.0;
fc.lim_use_sim_model = 1;
fc.limit_output = 1;
fc.limit_type = 1;
fc.lim_samples = 5;
fc.output_limit = [4.4, 8.1];

model_adlwm = simulation(fc, Ysp,1, u_nominal, params);
model_adlwm.save_csv('../wykresy/ph/disturbance/dl_my.csv', [40,100]);
model_adlwm.plot();

