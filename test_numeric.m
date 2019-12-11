op_points = [3, 5, 7, 8.5, 10];
D = 80;
N = D;
Nu = 5;
lambda_init = [0.01, 1, 0.1, 1, 0.1];
lambda_init = [0.01, 0.1, 0.02, 1, 0.1];
step_size = 0.1;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal);
fc.numeric = false;

Ysp = generate_setpoint();
model_a = simulation(fc, Ysp);

fc.numeric = true;
fc.use_full_steering = false;
fc.iterations = 0;
fc.sim_model = fm;
model_sl = simulation(fc, Ysp);


fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.iterations = 0;
fc.sim_model = fm;
model_sl_nlfr = simulation(fc, Ysp);

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.iterations = 1;
fc.sim_model = fm;
model_sl_nlfrc = simulation(fc, Ysp);

fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.iterations = 1;
fc.sim_model = Model([]);
model_n_real_model = simulation(fc, Ysp);