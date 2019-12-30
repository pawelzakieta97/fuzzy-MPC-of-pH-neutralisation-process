addpath('./membership_functions/');

D = 80;
N = D;
Nu = 5;
lambda = 0.1;

dmc_wm = DMC_WM(N, Nu, D, lambda);
dmc_wm.limit_output = 0;
dmc_wm.output_limit = [5,15];
Ysp = generate_setpoint();
model = simulation(dmc_wm, Ysp);
model.plot();

dmc_wm.limit_output = 1;
model1 = simulation(dmc_wm, Ysp);
model1.plot();