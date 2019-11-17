function times = resp_time_surf()
step_sizes = [0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2];
n_steps = 50;
min_step = 0.001;
max_step = 2;
k = (max_step/min_step)^(1/n_steps);
step_sizes = zeros(n_steps,1);
step_sizes(1) = min_step;
for i=2:n_steps
    step_sizes(i) = step_sizes(i-1)*k;
end
resolution = 100;
times = zeros(n_steps, resolution);
params = ModelParams();
params.Ts = 1;
for i = 1:length(step_sizes)
    i
    [~, t] = resp_time_char(resolution, step_sizes(i), params);
    times(i, :) = t;
end