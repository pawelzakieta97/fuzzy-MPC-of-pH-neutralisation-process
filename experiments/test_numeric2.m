addpath('../membership_functions/');
addpath('../');
op_points = [0.1, 0.5, 1];

% op_points = [3, 5, 7, 8.5, 10];
op_points = [0.2, 1];
op_points = [0.1, 0.8, 1.2];
op_points = [0.5, 0.9, 1.2];
op_points = [0.5, 1, 1.2];
op_points = [0.45, 0.7, 1, 1.15];
op_points = [0.4, 0.9, 1.15];
% op_points = [0.2, 0.6, 1.12];
D = 80;
N = D;
Nu = 40;
lambda_init = [3888, 3888, 3888];
step_size = 0.0005;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 2, 0);
fc.numeric = false;
% fc.set_sigmas([0.4,0.4,0.4]);
% fm.set_sigmas([0.4,0.4,0.4]);
% fc.set_sigmas([0.3,0.3, 0.3]);
% fm.set_sigmas([0.3,0.3, 0.3]);
% 
% fc.set_sigmas([0.3,0.2, 0.1]);
% fm.set_sigmas([0.3,0.2, 0.1]);
% 
% fc.set_sigmas([0.25,0.15, 0.08]);
% fm.set_sigmas([0.25,0.15, 0.08]);

fc.set_sigmas([0.2,0.2, 0.1]);
fm.set_sigmas([0.2,0.2, 0.1]);
fc.main_model.set_sigmas([0.2,0.2, 0.1]);

% sc = fm.generate_static_char(100);
% fc.main_model.static_in_char = fm.static_in_char;
% fc.main_model.static_char = fm.static_char;
% plot(sc);

% sc = fm.generate_static_char(100);
% fc.set_sigmas([1.1,0.38,1.2,0.43,1.53]);
% fc.main_model.set_sigmas([0.3,0.2, 0.1]);

params = Model2Params();
Ysp = random_signal(500, 150, [params.y_min, params.y_max], 1);
Ysp = [0.8*ones(70,1); 0.2*ones(80,1); 0.6*ones(60,1); 1.2*ones(70,1)];
Ysp = [0.4*ones(100,1); 0.6*ones(50,1); 0.8*ones(50,1); 1*ones(50,1); 1.2*ones(100,1)];
% Ysp = random_signal(500, 200, [0.45, 0.55], 1);
model_a = simulation(fc, Ysp,2);
model_a.plot();
model_a.save_csv('../wykresy/vdv/numeric/an.csv');
% 
% fc.numeric = true;
% fc.use_full_steering = false;
% fc.predict_lambdas = 0;
% fc.iterations = 0;
% fc.sim_model = fm;
% model_sl = simulation(fc, Ysp,2);
% model_sl.save_csv('../wykresy/vdv/numeric/sl.csv');


fc.reset();
fc.multi_lin = false;
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = fm;
model_slrn_fwm = simulation(fc, Ysp, 2);
model_slrn_fwm.plot();
model_slrn_fwm.save_csv('../wykresy/vdv/numeric/slrnfm.csv');

% fc.reset();
% fc.numeric = true;
% fc.use_full_steering = true;
% fc.predict_lambdas = 0;
% fc.iterations = 1;
% fc.sim_model = WienerModel(2);
% model_slrn_w = simulation(fc, Ysp, 2);
%model_slrn_w.save_csv('../wykresy/vdv/numeric/slrnwmf.csv');
% 
% fc.reset();
% fc.multi_lin = false;
% fc.numeric = true;
% fc.use_full_steering = true;
% fc.predict_lambdas = 0;
% fc.iterations = 1;
% fc.sim_model = fm;
% model_slrn_full = simulation(fc, Ysp, 2);
% model_slrn_full.save_csv('../wykresy/vdv/numeric/slrnfmf.csv');
% 
% fc.reset();
% fc.numeric = true;
% fc.multi_lin = true;
% fc.use_full_steering = true;
% fc.predict_lambdas = 0;
% fc.iterations = 1;
% fc.sim_model = fm;
% model_mlrn_full = simulation(fc, Ysp, 2);
% model_mlrn_full.plot();
% model_mlrn_full.save_csv('../wykresy/vdv/numeric/mlrnfmf.csv');
% 
% fc.reset();
% fc.numeric = true;
% fc.use_full_steering = true;
% fc.limit_output = false;
% fc.predict_lambdas = 0;
% fc.iterations = 1;
% fc.sim_model = Model2();
% model_n_real_model = simulation(fc, Ysp, 2);
% model_n_real_model.save_csv('../wykresy/vdv/numeric/real.csv');