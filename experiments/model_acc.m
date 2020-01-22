function error = model_acc(params)

error = 0;
op_points = params(1:3);
sigmas = params(4:6);
D = 100;
N = D;
Nu = 40;
lambda_init = [3600, 3600, 3600];
step_size = 0.0005;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 2, 0);
fc.numeric = false;
fc.set_sigmas(sigmas);
fm.set_sigmas(sigmas);
fc.main_model.set_sigmas(sigmas);
% Ysp = random_signal(500, 150, [params.y_min, params.y_max], 1);
Ysp = [0.8*ones(100,1); 0.2*ones(100,1); 0.6*ones(100,1); 1.2*ones(100,1)];
model_a = simulation(fc, Ysp,2);
fm.verify(model_a,0);
error = norm(fm.y(1:400)-model_a.y(1:400));