addpath('../membership_functions/');
addpath('../');

op_points = [2.96, 4.76, 6.7, 8.19, 10];
D = 80;
N = D;
Nu = 2;
step_size = 0.1;
lambda_init = [1,1,1,1,1];
[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 1);
fc.set_sigmas([0.6,0.6,0.6,0.6,0.6]);
fm.set_sigmas([0.6,0.6,0.6,0.6,0.6]);
Ysp = [5*ones(30,1); 8*ones(40,1); 4.5*ones(30,1)];
folder_name = 'simple/la';


fc.update_lambdas([0.1, 0.1, 0.1, 0.1, 0.1]);
fc.reset();
fc.numeric = true;
fc.multi_lin = true;
fc.use_full_steering = true;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = WienerModel(1);
model_mlrn_full_w = simulation(fc, Ysp,1);
model_mlrn_full_w.save_csv(['../wykresy/ph/wiener_best.csv']);

fc.update_lambdas([0.1, 0.1, 0.1, 0.1, 0.1]);
fc.reset();
fc.numeric = true;
fc.use_full_steering = true;
fc.limit_output = false;
fc.predict_lambdas = 0;
fc.iterations = 1;
fc.sim_model = Model(zeros(500,1));
model1_n_real_model = simulation(fc, Ysp,1);
model1_n_real_model.save_csv(['../wykresy/ph/real_best.csv']);