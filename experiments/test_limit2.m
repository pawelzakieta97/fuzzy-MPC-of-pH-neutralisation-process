addpath('../membership_functions/');
addpath('../');
% op_points = [3, 5, 7, 8.5, 10];
op_points = [0.2, 1];
op_points = [0.2, 0.8, 1.2];
D = 100;
N = D;
Nu = 40;
lambda_init = [3600, 3600, 3600];
step_size = 0.0005;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 2);
fc.numeric = false;
fc.set_sigmas([0.4,0.4,0.4]);
fm.set_sigmas([0.4,0.4,0.4]);
% fc.set_sigmas([0.3,0.3, 0.3]);
% fm.set_sigmas([0.3,0.3, 0.3]);
% fc.set_sigmas([1.1,0.38,1.2,0.43,1.53]);

params = Model2Params();
Ysp = random_signal(500, 200, [params.y_min, params.y_max], 1);
Ysp = [1.12*ones(100,1); 0.5*ones(200,1); 1.12*ones(200,1)];
% Ysp = [1.18*ones(100,1); 0.8*ones(300,1)];
Ysp = [1.12*ones(50,1); 0.8*ones(150,1); 1.12*ones(100,1);];

fc.limit_output = 0;
fc.limit_type = 2;
fc.output_limit = [0.79, 1.13];
model_a = simulation(fc, Ysp,2);
model_a.plot();
model_a.save_csv('../wykresy/vdv/ograniczenia/a.csv');

fc.limit_output = 1;
fc.lim_samples = 1;
model_al1 = simulation(fc, Ysp,2);
model_al1.plot();
model_al1.save_csv('../wykresy/vdv/ograniczenia/a1.csv');

fc.limit_output = 1;
fc.lim_samples = 15;
model_al15 = simulation(fc, Ysp,2);
model_al15.plot();
model_al15.save_csv('../wykresy/vdv/ograniczenia/a15.csv');

fc.lim_samples = 30;
model_al30 = simulation(fc, Ysp,2);
model_al30.plot();
model_al30.save_csv('../wykresy/vdv/ograniczenia/a30.csv');


