step_sizes = [0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2];
resolution = 100;
times = zeros(length(step_sizes), resolution);
params = ModelParams();
params.Ts = 1;
for i = 1:length(step_sizes)
    [~, t] = resp_time_char(resolution, step_sizes(i), params);
    times(i, :) = t;
end