addpath('../membership_functions/');
addpath('../');
op_points = [0.1, 0.5, 1];
% op_points = [3, 5, 7, 8.5, 10];
op_points = [0.2, 1];
% op_points = [0.2, 0.6, 1.12];
D = 100;
N = D;
Nu = 40;
lambda_init = [5000, 5000, 5000];
step_size = 0.0005;

[fc, fm] = get_fuzzy_controller(op_points, lambda_init, step_size, @normal, Nu, 2);
samples = length(fc.controllers(1).linear_model.s1);
steps = length(fc.controllers);
s = zeros(samples, steps);
for k=1:length(fc.controllers)
    s(:,k) = fc.controllers(k).linear_model.s1/3600;
end
params = Model2Params();
csvwrite_with_headers('../wykresy/vdv/steps.csv', [s, ([1:samples]*params.Ts)'], {'s1', 's2', 't'});