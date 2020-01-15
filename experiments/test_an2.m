addpath('../membership_functions/');
addpath('../');
op_points = [0.1, 0.5, 1];
% op_points = [3, 5, 7, 8.5, 10];
op_points = [0.2, 1];
%op_points = 0.6;
% op_points = [0.2, 0.8, 1.2];
D = 100;
N = D;
Nu = 40;
lambda_init = [3600, 3600, 3600];
lambda_init = [360000, 360000, 36000];
step_size = 0.0005;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 2);
fc.numeric = false;
fc.set_sigmas([0.4,0.4,0.4]);
fm.set_sigmas([0.4,0.4,0.4]);

fc.set_sigmas([0.3,0.3, 0.3]);
fm.set_sigmas([0.3,0.3, 0.3]);

% fc.set_sigmas([1.1,0.38,1.2,0.43,1.53]);

params = Model2Params();
Ysp = random_signal(500, 150, [params.y_min, params.y_max], 1);
Ysp = [0.8*ones(200,1); 0.2*ones(200,1); 0.6*ones(200,1); 1.2*ones(200,1)];
% Ysp = random_signal(500, 200, [0.45, 0.55], 1);
model_a = simulation(fc, Ysp,2);
model_a.plot();
model_a.save_csv('../wykresy/vdv/solo360000.csv');

fc.update_lambdas([3600, 3600]);
model_a2 = simulation(fc, Ysp,2);
model_a2.plot();
model_a2.save_csv('../wykresy/vdv/solo3600.csv');



