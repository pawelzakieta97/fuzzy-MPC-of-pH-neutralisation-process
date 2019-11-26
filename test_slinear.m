addpath('./membership_functions/');
op_points = [3, 5, 7, 8.5, 10];

D = 50;
N = D;
Nu = 2;
lambda = 1;
step_size = 0.1;
op_point = 7;
params = ModelParams();
output_limit = [params.u1_min, params.u1_max];
[~, s] = SLinear_step(7, 1, 100);
s = s(2:end)-s(1);
s = s/step_size;
s = s';
dmc = DMC(s, N, Nu, D, lambda, op_point, step_size, output_limit);
params = ModelParams();

model = SLinear_simulation(dmc, generate_setpoint());

model.plot()
