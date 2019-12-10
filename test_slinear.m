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
[~, s] = SLinear_step(7, step_size, 100);
s = s';
step_model = StepRespModel(s, step_size, ModelParams());
dmc = DMC(step_model,N,Nu,D,lambda);
params = ModelParams();
Ysp = generate_setpoint();
model = SLinear_simulation(dmc, Ysp);
du = model.u_in(1:500)-[model.u_in(1);model.u_in(1:499)];
du_exp = zeros(499,1);
% for k=1:500
%     du_exp(k) = expected_step(model, k);
% end
% stairs(du);
% hold on;
% stairs(du_exp);
model.plot()
