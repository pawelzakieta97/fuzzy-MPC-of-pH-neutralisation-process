addpath('./membership_functions/');

op_points = [3, 4.6, 6.4, 8, 10];
op_points = [2.96, 4.76, 6.7, 8.19, 10]
% op_points = [3, 5, 7, 8.5, 10];
% op_points = [7];
D = 80;
N = D;
Nu = 40;
lambda_init = [0.1, 1, 0.05, 0.1, 0.1];
lambda_init = [0.2, 0.5, 0.1, 0.1, 0.1];
lambda_init = [0.01, 1, 0.1, 1, 0.1];
% lambda_init = [0.1, 0.1, 0.1, 0.1, 0.1];
% lambda_init = [0.01, 0.1, 0.02, 1, 0.1];
% lambda_init = [1];
%lambda_init = [0.1, 1, 0.2, 10, 1];
step_size = 0.1;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 1);
fc.numeric = false;
fc.set_sigmas([1,1,1,1,1]);
fm.set_sigmas([1,1,1,1,1]);
% fc.set_sigmas([1.1,0.38,1.2,0.43,1.53]);

Ysp = generate_setpoint();
% Ysp = (Ysp-mean(Ysp))/20+7;
% Ysp = random_signal(500, 100, [6.9, 7.1], 1);
model_a = simulation(fc, Ysp,1);
model_a.plot();

fc.output_limit = [0,0];
model_al = simulation(fc, Ysp,1);

fc.numeric = true;
fc.use_full_steering = false;
fc.predict_lambdas = 0;
fc.iterations = 0;
fc.sim_model = WienerModel(1);
model_sl = simulation(fc, Ysp,1);

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 0;
fc.sim_model = fm;
model_slrn_fm = simulation(fc, Ysp,1);

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 0;
fc.sim_model = WienerModel(1);
model_slrn = simulation(fc, Ysp,1);

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = WienerModel(1);
model_slrn_full = simulation(fc, Ysp,1);


fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.predict_current_state = true;
fc.sim_model = WienerModel(1);
model_slrn_full_pcs = simulation(fc, Ysp,1);

fc.reset();
fc.numeric = true;
fc.multi_lin = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = WienerModel(1);
model_mlrn_full_w = simulation(fc, Ysp,1);

fc.reset();
fc.numeric = true;
fc.multi_lin = true;
fc.use_full_steering = true;
fc.iterations = 1;
fc.predict_lambdas = 1;
fc.sim_model = WienerModel(1);
model_mlrn_full_pl = simulation(fc, Ysp,1);


fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.limit_output = false;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = Model(zeros(500,1));
model_n_real_model = simulation(fc, Ysp,1);