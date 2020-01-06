addpath('./membership_functions/');
addpath('../');
op_points = [0, 3];
% op_points = [3, 5, 7, 8.5, 10];
% op_points = [7];
D = 130;
N = D;
Nu = 40;
lambda_init = [2000, 2000];
step_size = 0.001;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 2);
fc.numeric = false;
fc.set_sigmas([1,1]);
% fc.set_sigmas([1.1,0.38,1.2,0.43,1.53]);

params = Model2Params();
Ysp = random_signal(500, 100, [params.y_min, params.y_max], 1);
model_a = simulation(fc, Ysp,2);
model_a.plot();

fc.output_limit = [0,0];
model_al = simulation(fc, Ysp);

fc.numeric = true;
fc.use_full_steering = false;
fc.predict_lambdas = 0;
fc.iterations = 0;
fc.sim_model = WienerModel();
model_sl = simulation(fc, Ysp);


fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 0;
fc.sim_model = WienerModel();
model_slrn = simulation(fc, Ysp);

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = WienerModel();
model_slrn_full = simulation(fc, Ysp);


fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.predict_current_state = true;
fc.sim_model = WienerModel();
model_slrn_full_pcs = simulation(fc, Ysp);

fc.reset();
fc.numeric = true;
fc.multi_lin = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = WienerModel();
model_mlrn_full_w = simulation(fc, Ysp);

fc.reset();
fc.numeric = true;
fc.multi_lin = true;
fc.use_full_steering = true;
fc.iterations = 1;
fc.predict_lambdas = 1;
fc.sim_model = WienerModel();
model_mlrn_full_pl = simulation(fc, Ysp);


fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.limit_output = false;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = Model(zeros(500,1));
model_n_real_model = simulation(fc, Ysp);