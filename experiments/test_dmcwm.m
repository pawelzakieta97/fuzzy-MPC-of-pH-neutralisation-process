addpath('../')
addpath('./membership_functions/');

D = 80;
N = D;
Nu = 2;
lambda = 0.5;

dmc_wm = DMC_WM(N, Nu, D, lambda, @static_inv, 1);
dmc_wm.limit_output = 0;
dmc_wm.output_limit = [5,15];
Ysp = generate_setpoint();
Ysp = [5*ones(30,1); 8*ones(40,1); 4.5*ones(30,1)];
model_wm = simulation(dmc_wm, Ysp, 1);
model_wm.plot();
model_wm.save_csv('../wykresy/ph/dmc_wiener.csv');