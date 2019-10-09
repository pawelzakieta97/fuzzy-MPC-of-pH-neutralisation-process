function [u, y] = static_char(samples, signal, params)

if nargin<3
    params = ModelParams();
end
y = zeros(samples,1);
u = repmat(params.u_nominal, [samples, 1]);
if signal == 1
    u(:,1) = [1:samples]/samples*(params.u1_max-params.u1_min)+params.u1_min;
else
    u(:,2) = [1:samples]/samples*(params.u2_max-params.u2_min)+params.u2_min;
end
for k =1:samples
    [~,y(k)] = static_output(u(k,:), params);
end