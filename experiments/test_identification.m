addpath('./membership_functions/');
addpath('../');

op_points = [2.96, 4.76, 6.7, 8.19, 10];
D = 80;
N = D;
Nu = 40;
lambda_init = [0.1, 1, 0.05, 0.1, 0.1];
lambda_init = [0.2, 0.5, 0.1, 0.1, 0.1];
lambda_init = [1,1,1,1,1];
step_size = 0.1;

sigmas = [0.3,0.5,0.3,0.5,0.3];

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 1);
fc.numeric = false;
fc.set_sigmas(sigmas);
fc.main_model.set_sigmas(sigmas);
fm.set_sigmas(sigmas);
%fc.update_lambdas([0.1,1,0.1,1,0.1]);
Ysp = generate_setpoint();
Ysp = [4*ones(50,1); 5*ones(50,1); 6*ones(50,1); 7*ones(50,1); 8*ones(50,1); 9*ones(50, 1); 10*ones(50,1)];
% range = [op_points(1)-0.1, op_points(1)+0.1];
model1_a = simulation(fc, Ysp,1);
fm.verify(model1_a,1);

