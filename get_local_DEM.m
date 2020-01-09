function dem = get_local_DEM(y0, signal_idx, model_idx)
if nargin<3
    model_idx = 1;
end
if model_idx == 1
    if nargin<2
        signal_idx = 1;
    end
    u0 = static_inv(y0);
    u1 = random_signal(400, 40, [u0(signal_idx)-0.5, u0(signal_idx)+0.5]);
    params = ModelParams();
    u = repmat(params.u_nominal, [400,1]);
    u(:, signal_idx) = u1;
    model = Model(zeros(400,1));
    model.update(u);
    dem = DiffEqModel(u1, model.y, 1, 1, params);
else
    if nargin<2
        signal_idx = 1;
    end
    u0 = static_inv2(y0);
    u1 = random_signal(400, 40, [u0(signal_idx)-0.001, u0(signal_idx)+0.001]);
    params = Model2Params();
    u = repmat(params.u_nominal, [400,1]);
    u(:, signal_idx) = u1;
    model = Model2(zeros(400,1));
    model.update(u);
    dem = DiffEqModel(u1, model.y, 1, 1, params);
end