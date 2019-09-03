function characterictic = static_char(samples, signal)
Constants;
characterictic = zeros(samples,1);
u = repmat(u_nominal, [samples, 1]);
if signal == 1
    u(:,1) = [1:samples]/samples*(u1_max-u1_min)+u1_min;
else
    u(:,2) = [1:samples]/samples*(u2_max-u2_min)+u2_min;
end
for k =1:samples
    [~,characterictic(k)] = static_output(u(k,:));
end