function dem = get_local_DEM(y0, signal_idx, model_idx, normalize)
if nargin<4
    normalize =0;
end
if nargin<3
    model_idx = 1;
end
if model_idx == 1
    if nargin<2
        signal_idx = 1;
    end
    u0 = static_inv(y0);
    u1 = random_signal(2000, 200, [u0(signal_idx)-0.5, u0(signal_idx)+0.5], 1);
    u1 = u1-mean(u1)+u0(1);
    params = ModelParams();
    u = repmat(params.u_nominal, [2000,1]);
    u(:, signal_idx) = u1;
    model = Model(zeros(2000,1));
    model.update(u);
    u = u(200:end, 1);
    y = model.y(200:end);
    if normalize
        amp_y = max(y) - min(y);
        amp_u = max(u) - min(u);
        u = u / amp_u * amp_y;
        u = u + min(y)-min(u);
    end
    dem = DiffEqModel(u, y, 1, 2, params);
else
    if nargin<2
        signal_idx = 1;
    end
    u0 = static_inv2(y0);
    u1 = random_signal(2000, 300, [u0(signal_idx)-0.0001, u0(signal_idx)+0.0001], 1);
    params = Model2Params();
    u = repmat(params.u_nominal, [2000,1]);
    u(:, signal_idx) = u1;
    model = Model2(zeros(2000,1));
    model.update(u);
    u = u(200:end, 1);
    y = model.y(200:end);
    if normalize
        amp_y = max(y) - min(y);
        amp_u = max(u) - min(u);
        u = u / amp_u * amp_y;
        u = u + min(y)-min(u);
    end
    dem = DiffEqModel(u, y, 2, 2, params);
end