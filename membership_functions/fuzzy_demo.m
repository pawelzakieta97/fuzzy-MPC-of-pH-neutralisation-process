sim_len = 500;
op_points = [3, 5, 7, 8.5, 10];
weights = zeros(sim_len, 5);
x = (1:500)*9/500+2;
for i=1:sim_len
    for op = 1:5
        weights(i, op) = gaussmf(x(i), [1, op_points(op)]);
    end
end

plot(x, weights)
xlabel('x');
ylabel('waga');
legend('funkcja przynależności 1', 'funkcja przynależności 2', 'funkcja przynależności 3', 'funkcja przynależności 4', 'funkcja przynależności 5', 'Location', 'southeast');