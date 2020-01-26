addpath('./membership_functions/');
addpath('../');

op_points = [6.7, 5.7];
D = 80;
N = D;
Nu = 40;
lambda_init = [1, 1];
step_size = 0.05;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 1);
%fc.numeric = false;

sigmas = [0.4,0.5,0.2,0.5,0.4];
sigmas = [0.3,0.5,0.3,0.5,0.3];
fc.set_sigmas(sigmas);
fm.set_sigmas(sigmas);
fc.main_model.set_sigmas(sigmas);
%fc.update_lambdas([1]);
Ysp = generate_setpoint();
Ysp = [4*ones(40,1); 5*ones(40,1); 6*ones(40,1); 7*ones(40,1); 8*ones(40,1); 9*ones(40, 1); 10*ones(40,1)];
%Ysp = [3.5*ones(50,1);5*ones(80,1); 6*ones(50,1); 6.5*ones(50,1); 8*ones(50,1); 10*ones(50,1)];
folder_name = '01';
model1_a = simulation(fc, Ysp,1);
model1_a.plot();
model1_a.save_csv(['../wykresy/ph/',folder_name,'/lin.csv']);

