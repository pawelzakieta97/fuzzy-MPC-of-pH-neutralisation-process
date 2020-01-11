addpath('../membership_functions/');
addpath('../');
op_points = [0.1, 0.5, 1];
% op_points = [3, 5, 7, 8.5, 10];
op_points = [0.2, 1];
% op_points = [0.2, 0.6, 1.12];
D = 80;
N = D;
Nu = 40;
lambda_init = [5000, 5000, 5000];
step_size = 0.0005;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 2);
fc.numeric = false;
fc.set_sigmas([0.4,0.4,0.4]);
fm.set_sigmas([0.4,0.4,0.4]);
% fc.set_sigmas([1.1,0.38,1.2,0.43,1.53]);

params = Model2Params();
Ysp = random_signal(500, 150, [params.y_min, params.y_max], 1);
Ysp = [0.8*ones(200,1); 0.2*ones(200,1); 0.6*ones(200,1); 1.2*ones(200,1)];
% Ysp = random_signal(500, 200, [0.45, 0.55], 1);
model_a = simulation(fc, Ysp,2);
model_a.plot();
model_a.save_csv('../wykresy/druga/02 1 5000 5000/analityczny2.csv');

fc.numeric = true;
fc.use_full_steering = false;
fc.predict_lambdas = 0;
fc.iterations = 0;
fc.sim_model = fm;
model_sl = simulation(fc, Ysp,2);
model_sl.save_csv('../wykresy/druga/02 1 5000 5000/sl.csv');


fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 0;
fc.sim_model = fm;
model_slrn_fm = simulation(fc, Ysp, 2);
model_slrn_fm.save_csv('../wykresy/druga/02 1 5000 5000/slrnfm.csv');

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = WienerModel(2);
model_slrn_w = simulation(fc, Ysp, 2);
model_slrn_w.save_csv('../wykresy/druga/02 1 5000 5000/slrnwmf.csv');

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = fm;
model_slrn_full = simulation(fc, Ysp, 2);
model_slrn_full.save_csv('../wykresy/druga/02 1 5000 5000/slrnfmf.csv');

fc.reset();
fc.numeric = true;
fc.multi_lin = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = fm;
model_mlrn_full = simulation(fc, Ysp, 2);
model_mlrn_full.save_csv('../wykresy/druga/02 1 5000 5000/mlrnfmf.csv');

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.limit_output = false;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = Model2();
model_n_real_model = simulation(fc, Ysp, 2);
model_n_real_model.save_csv('../wykresy/druga/02 1 5000 5000/real.csv');