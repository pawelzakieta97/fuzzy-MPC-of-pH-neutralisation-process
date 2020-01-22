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
step_size = 0.1;

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
%model1_a = simulation(fc, Ysp,1, u_nominal, params);
model1_a.plot();

fc.reset();
fc.set_include_disturbance(1);

params = ModelParams();
%model1_a1 = simulation(fc, Ysp,1, u_nominal, params);
model1_a1.plot();

fc.linearize_sim_model = 1;
fc.sim_model = WienerModel(1);
%Ysp = [5*ones(30,1); 8*ones(40,1); 4.5*ones(30,1)];
fc.lim_use_sim_model = 1;
fc.limit_output = 1;
fc.limit_type = 2;
fc.lim_samples = 5;
fc.output_limit = [4.4, 8.1];

model_al1 = simulation(fc, Ysp,1, u_nominal, params);
model_al1.plot();

