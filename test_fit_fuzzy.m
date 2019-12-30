[u, y] = static_char(100, 1);
u1 = u(:,1);
[op_points, sigmas] = fit_fuzzy_params(y, u1, 5);
