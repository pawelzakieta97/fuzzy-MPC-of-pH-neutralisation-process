addpath('./membership_functions/');

op_points = [3, 5, 7, 8.5, 10];
%op_points = [7];
D = 80;
N = D;
Nu = 5;
% lambda_init = [0.01, 1, 0.1, 1, 0.1];
lambda_init = [0.1, 0.1, 0.1, 0.1, 0.1];
% lambda_init = [0.01, 0.1, 0.02, 1, 0.1];
% lambda_init = [1];
%lambda_init = [0.1, 1, 0.2, 10, 1];
step_size = 0.1;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal);
fc.numeric = false;

Ysp = generate_setpoint();
% Ysp = (Ysp-mean(Ysp))/20+7;
% Ysp = random_signal(500, 100, [6.9, 7.1], 1);
model_a = simulation(fc, Ysp);
model_a.plot();

fc.output_limit = [0,0];
model_al = simulation(fc, Ysp);

fc.numeric = true;
fc.use_full_steering = false;
fc.iterations = 0;
fc.sim_model = WienerModel();
model_sl = simulation(fc, Ysp);


fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.iterations = 0;
fc.sim_model = WienerModel();
model_slrn = simulation(fc, Ysp);

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.iterations = 1;
fc.sim_model = WienerModel();
model_slrn_full = simulation(fc, Ysp);


fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.iterations = 1;
fc.predict_current_state = true;
fc.sim_model = WienerModel();
model_slrn_full_pcs = simulation(fc, Ysp);

fc.reset();
fc.numeric = true;
fc.multi_lin = true;
fc.use_full_steering = true;
fc.iterations = 1;
fc.sim_model = WienerModel();
model_mlrn_full_w = simulation(fc, Ysp);

fc.reset();
fc.numeric = true;
fc.multi_lin = true;
fc.use_full_steering = true;
fc.iterations = 1;
fc.limit_output = true;
fc.output_limit = [0, 8.05];
fc.sim_model = WienerModel();
model_mlrn_full_wl = simulation(fc, Ysp);

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.limit_output = false;
fc.iterations = 1;
fc.sim_model = Model([]);
model_n_real_model = simulation(fc, Ysp);