
[u, y] = static_char(1000, 1);
plot(u(:,1),y)
hold on;
u1 = u(:,1);
training_data = [u1, y];
op_points = [0, 14, 30];
values = [2.5, 6.5, 10.57];
sigmas = [6,6,6];
samples = length(u1);
ys = zeros(samples, 1);
for k=1:samples
    u_local = u1(k);
    value = 0;
    total_weight = 0;
    for ref_idx=1:length(values)
        weight = gaussmf(u_local, [sigmas(ref_idx), op_points(ref_idx)]);
        total_weight = total_weight+weight;
        value = value+values(ref_idx)*weight;
    end
    ys(k) = value/total_weight;
end
plot(u1,ys);