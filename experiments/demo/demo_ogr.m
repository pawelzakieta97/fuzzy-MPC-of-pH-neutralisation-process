D = 80;
N = 80;
%y = y_1*0.9+0.2*u;
a = 0.8;
b = 0.4;
s = zeros(D,1);
y_1 = 0;
Nu = 10;
for k = 1 : D
    s(k) = y_1*a + b;
    y_1 = s(k);
end
Mp = generateMp(N, D, s);
M = generateM(N, Nu, D, s);
lambda = 10;
K = (M'*M + eye(Nu)*lambda)^(-1)*M';

sim_len = 50;
Ysp = [zeros(5,1); 2*ones(45,1)];
y = zeros(sim_len,1);
y_1 = 0;
u_1 = 0;
u = zeros(sim_len, 1);
lim = 2.2;
thr = 0.3;
limit = 0;
for k=1:sim_len
    u_temp = [zeros(D,1); u];
    du = u_temp(k+D-1:-1:k+1) - u_temp(k+D-2:-1:k);
    a1 = 0.9;
    b1 = 0.2;
    y(k) = y_1*a1 + u_1 * b1;
    u_max = 999;
    if y(k)>lim-thr
        u_max = lim/2;
    end
    u(k) = u_1 + K(1,:)*((Ysp(k) - y(k))*ones(N,1) - Mp*du);
    if limit
        u(k) = min(u_max, u(k));
    end
    y_1 = y(k);
    u_1 = u(k);
end
csvwrite_with_headers('../../wykresy/demo/no_lim.csv', [[1:sim_len]', u,y, Ysp], {'t', 'u', 'y', 'ysp'})

y = zeros(sim_len,1);
y_1 = 0;
u_1 = 0;
u = zeros(sim_len, 1);
limit = 1;
for k=1:sim_len
    u_temp = [zeros(D,1); u];
    du = u_temp(k+D-1:-1:k+1) - u_temp(k+D-2:-1:k);
    a1 = 0.9;
    b1 = 0.2;
    y(k) = y_1*a1 + u_1 * b1;
    u_max = 999;
    if y(k)>lim-thr
        u_max = lim/2;
    end
    u(k) = u_1 + K(1,:)*((Ysp(k) - y(k))*ones(N,1) - Mp*du);
    if limit
        u(k) = min(u_max, u(k));
    end
    y_1 = y(k);
    u_1 = u(k);
end
csvwrite_with_headers('../../wykresy/demo/lim.csv', [[1:sim_len]', u,y, Ysp], {'t', 'u', 'y', 'ysp'})