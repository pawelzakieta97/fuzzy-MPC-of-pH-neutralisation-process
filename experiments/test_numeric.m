addpath('./membership_functions/');
addpath('../');

op_points = [3, 4.6, 6.4, 8, 10];
op_points = [2.96, 4.76, 6.7, 8.19, 10]
% op_points = [3, 5, 7, 8.5, 10];
% op_points = [7];
D = 80;
N = D;
Nu = 40;
lambda_init = [0.1, 1, 0.05, 0.1, 0.1];
lambda_init = [0.2, 0.5, 0.1, 0.1, 0.1];
lambda_init = [0.1, 1, 0.1, 1, 0.1];
step_size = 0.05;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 1);
fc.numeric = false;

sigmas = [0.4,0.5,0.2,0.5,0.4];
sigmas = [0.3,0.5,0.2,0.5,0.3];
fc.set_sigmas(sigmas);
fm.set_sigmas(sigmas);
fc.main_model.set_sigmas(sigmas);
fc.update_lambdas([1,1,1,1,1]);
Ysp = generate_setpoint();
Ysp = [4*ones(50,1); 5*ones(50,1); 6*ones(50,1); 7*ones(50,1); 8*ones(50,1); 9*ones(50, 1); 10*ones(50,1)];
%Ysp = [3.5*ones(50,1);5*ones(80,1); 6*ones(50,1); 6.5*ones(50,1); 8*ones(50,1); 10*ones(50,1)];
folder_name = '01';
model1_a = simulation(fc, Ysp,1);
model1_a.plot();
model1_a.save_csv(['../wykresy/ph/',folder_name,'/analityczny.csv']);

fc.numeric = true;
fc.use_full_steering = false;
fc.predict_lambdas = 0;
fc.iterations = 0;
fc.sim_model = WienerModel(1);
model1_sl = simulation(fc, Ysp,1);
model1_sl.save_csv(['../wykresy/ph/',folder_name,'/sl.csv']);

% fc.reset();
% fc.numeric = true;
% fc.use_full_steering = true;
% fc.predict_lambdas = 0;
% fc.iterations = 1;
% fc.sim_model = fm;
% model1_slrn_fm = simulation(fc, Ysp,1);
% model1_slrn_fm.save_csv(['../wykresy/ph/',folder_name,'/slrnfm.csv']);

fc.reset();
fc.numeric = true;
fc.multi_lin = 0;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 0;
fc.sim_model = WienerModel(1);
fc.main_model = WienerModel(1);
model1_slrn = simulation(fc, Ysp,1);
model1_slrn.save_csv(['../wykresy/ph/',folder_name,'/slrnwm.csv']);

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = WienerModel(1);
model1_slrn_full = simulation(fc, Ysp,1);
model1_slrn_full.save_csv(['../wykresy/ph/',folder_name,'/slrnwmf.csv']);

% fc.reset();
% fc.numeric = true;
% fc.use_full_steering = true;
% fc.predict_lambdas = 0;
% fc.iterations = 1;
% fc.predict_current_state = true;
% fc.sim_model = WienerModel(1);
% model_slrn_full_pcs = simulation(fc, Ysp,1);
% model_slrn_full_pcs.save_csv(['../wykresy/ph/',folder_name,'/slrnwmfpcs.csv']);

fc.reset();
fc.numeric = true;
fc.multi_lin = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = WienerModel(1);
model_mlrn_full_w = simulation(fc, Ysp,1);
model_mlrn_full_w.save_csv(['../wykresy/ph/',folder_name,'/mlrn.csv']);

% fc.reset();
% fc.numeric = true;
% fc.multi_lin = true;
% fc.use_full_steering = true;
% fc.iterations = 1;
% fc.predict_lambdas = 1;
% fc.sim_model = WienerModel(1);
% model1_mlrn_full_pl = simulation(fc, Ysp,1);
% model1_mlrn_full_pl.save_csv('mlrnfullpl_01_1_01_1_01.csv');

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.limit_output = false;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = Model(zeros(500,1));
fc.main_model = Model(zeros(500,1));
model1_n_real_model = simulation(fc, Ysp,1);
model1_n_real_model.save_csv(['../wykresy/ph/',folder_name,'//real.csv']);