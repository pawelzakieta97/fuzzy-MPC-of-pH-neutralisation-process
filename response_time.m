function time = response_time(u0, step_size, params, fraction)
if nargin<4
    fraction = 1-exp(-1);
end
if nargin<3
    params = ModelParams();
end
%[~, s] = step(u0, step_size, 200, params);
model = Model([], params);
[x0,y0] = static_output(u0);
[~, y_stat] = static_output(u0+[step_size, 0, 0]);
model.x(1,:)=x0;
model.y(1)=y0;
time = 0;
if step_size>0
    while model.y(model.k)<y0+(y_stat-y0)*fraction
        time = time + 1;
        model.update(u0+[step_size, 0, 0]);
    end
end
time = time*params.Ts;
