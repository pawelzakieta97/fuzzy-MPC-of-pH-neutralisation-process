function dem = get_local_DEM(y0, signal_idx, model_idx)
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
    dem = DiffEqModel(u1(200:end), model.y(200:end), 1, 2, params);
else
    if nargin<2
        signal_idx = 1;
    end
    u0 = static_inv2(y0);
    u1 = random_signal(1000, 200, [u0(signal_idx)-0.0001, u0(signal_idx)+0.0001], 1);
    params = Model2Params();
    u = repmat(params.u_nominal, [1000,1]);
    u(:, signal_idx) = u1;
    model = Model2(zeros(1000,1));
    model.update(u);
    dem = DiffEqModel(u1(200:end), model.y(200:end), 1, 1, params);
end