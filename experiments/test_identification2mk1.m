addpath('../membership_functions/');
addpath('../');
op_points = [0.4, 0.9, 1.15];
D = 100;
N = D;
Nu = 40;
lambda_init = [3600, 3600, 3600, 3600];
step_size = 0.0005;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 2, 0);
fc.numeric = false;

% fc.set_sigmas([0.3,0.3, 0.3]);
% fm.set_sigmas([0.3,0.3, 0.3]);
% 
% fc.set_sigmas([0.25,0.1, 0.08]);
% fm.set_sigmas([0.25,0.1, 0.08]);

fc.set_sigmas([0.2,0.2, 0.1, 0.07]);
fm.set_sigmas([0.2,0.2, 0.1, 0.07]);
fc.main_model.set_sigmas([0.2,0.2, 0.1, 0.07]);

% sc = fm.generate_static_char(100);
% fc.main_model.static_in_char = fm.static_in_char;
% fc.main_model.static_char = fm.static_char;
% fc.set_sigmas([0.3,0.2, 0.1]);
% fm.set_sigmas([0.3,0.2, 0.1]);
% sc = fm.generate_static_char(100);
u = 1/100*[1:100]*(fm.params.u_max(1)- fm.params.u_min(1))+fm.params.u_min(1);
u = u * 3600;
sc(1) = 0.05;
plot(sc);
params = Model2Params();
% Ysp = random_signal(500, 150, [params.y_min, params.y_max], 1);
Ysp = [0.8*ones(100,1); 0.2*ones(100,1); 0.6*ones(100,1); 1.2*ones(100,1)];
range = [op_points(1)-0.03, op_points(1)+0.03];
% Ysp = random_signal(1000, 200, range, 1);
% Ysp = random_signal(500, 200, [0.45, 0.55], 1);
model_a = simulation(fc, Ysp,2);
fm.verify(model_a,1);
fm.y_ref = model_a.y;
fm.save_csv('../wykresy/vdv/identification/fwm.csv');
% 
wm = WienerModel(2);
wm.verify(model_a,1);
wm.y_ref = model_a.y;
wm.save_csv('../wykresy/vdv/identification/wm.csv');

fc.save_csv_mf('../wykresy/vdv/identification/mf.csv');
fc.save_csv_s('../wykresy/vdv/identification/s.csv');
% 
% 
% [fc1, fm1] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 2, 0);
% fc.numeric = false;
% 
% fc1.set_sigmas([0.3,0.3, 0.3]);
% fm1.set_sigmas([0.3,0.3, 0.3]);
% 
% fc1.set_sigmas([0.3,0.2, 0.1]);
% fm1.set_sigmas([0.3,0.2, 0.1]);
% fm1.verify(model_a,1);
% fm1.y_ref = model_a.y;
% fm1.save_csv('../wykresy/vdv/identification/fm.csv');