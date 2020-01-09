addpath('./membership_functions/');
addpath('../')

D = 80;
N = D;
Nu = 40;
lambda = 0.5;


Ysp = random_signal(500, 200, [params.y_min, params.y_max], 1);
dmc_wm = DMC_WM(N, Nu, D, lambda, @static_inv2, 2);
dmc_wm.limit_output = 0;
dmc_wm.static_inv = @static_inv2;
model = simulation(dmc_wm, Ysp, 2);
model.plot();

% dmc_wm.limit_output = 1;
% model1 = simulation(dmc_wm, Ysp, 2);
% model1.plot();