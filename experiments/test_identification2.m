addpath('../membership_functions/');
addpath('../');
op_points = [0.2, 0.9, 1.2];
% op_points = [1.2]
% op_points = [1.12];
%op_points = [0.2, 1];
D = 100;
N = D;
Nu = 40;
lambda_init = [3600, 3600, 3600];
%lambda_init = [360000, 360000, 36000];
step_size = 0.0005;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 2);
fc.numeric = false;

fc.set_sigmas([0.3,0.3, 0.3]);
fm.set_sigmas([0.3,0.3, 0.3]);

fc.set_sigmas([0.3,0.2, 0.1]);
fm.set_sigmas([0.3,0.2, 0.1]);

% fc.set_sigmas([1.1,0.38,1.2,0.43,1.53]);

params = Model2Params();
% Ysp = random_signal(500, 150, [params.y_min, params.y_max], 1);
Ysp = [0.8*ones(100,1); 0.2*ones(100,1); 0.6*ones(100,1); 1.2*ones(100,1)];
range = [op_points(1)-0.03, op_points(1)+0.03];
% Ysp = random_signal(1000, 200, range, 1);
% Ysp = random_signal(500, 200, [0.45, 0.55], 1);
model_a = simulation(fc, Ysp,2);
fm.verify(model_a,1);



