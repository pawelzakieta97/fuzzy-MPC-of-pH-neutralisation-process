function time = response_time(u0, step_size, fraction, params)
if nargin<3
    farction = 1-exp(-1);
end
if nargin<4
    params = ModelParams();
end
[~, s] = step(u0, step_size, 200, params);
[~, y_stat] = static_output(u0+[0, step_size, 0], params);
[~, idx] = min(abs(s-(y_stat-(y_stat-s(1))/exp(1))));
time = idx*params.Ts;