function [u, y] = static_char(samples, signal, model_idx, params)
if nargin<3
    model_idx = 1;
    params = ModelParams();
end
if nargin<4
    if model_idx == 1
        params = ModelParams();
    else
        params = Model2Prams();
    end
end
y = zeros(samples,1);
u = repmat(params.u_nominal, [samples, 1]);
if model_idx == 1
    if signal == 1
        u(:,1) = [1:samples]/samples*(params.u1_max-params.u1_min)+params.u1_min;
    else
        u(:,2) = [1:samples]/samples*(params.u2_max-params.u2_min)+params.u2_min;
    end
    for k =1:samples
        [~,y(k)] = static_output(u(k,:), params);
    end
else
    m = Model2([]);
    u(:,1) = [1:samples]/samples*(params.u1_max-params.u1_min)+params.u1_min;
    for k =1:samples
        [~,y(k)] = static_output(u(k,:), params);
    end
end