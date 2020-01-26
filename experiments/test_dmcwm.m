addpath('../')
addpath('./membership_functions/');

D = 80;
N = D;
Nu = 40;
lambda = 1;

dmc_wm = DMC_WM(N, Nu, D, lambda, @static_inv, 1);
dmc_wm.limit_output = 0;
dmc_wm.output_limit = [5,15];
Ysp = generate_setpoint();

Ysp = [4*ones(40,1); 5*ones(40,1); 6*ones(40,1); 7*ones(40,1); 8*ones(40,1); 9*ones(40, 1); 10*ones(40,1)];
model_wm = simulation(dmc_wm, Ysp, 1);
model_wm.plot();
%model_wm.save_csv('../wykresy/ph/dmc_wiener.csv');

Ysp = [5*ones(30,1); 8*ones(40,1); 4.5*ones(30,1)];
model_wm = simulation(dmc_wm, Ysp, 1);
model_wm.plot();
%model_wm.save_csv('../wykresy/ph/dmc_wiener_simple.csv');