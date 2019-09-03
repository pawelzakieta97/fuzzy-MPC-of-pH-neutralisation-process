function u = static_inv(y_stat, u_idx, threshold)
% funkcja zwracaj�ca warto�� sygna��w steruj�cych u, dla kt�rych
% uzyskiwane jest wzmocnienie y_stat (szukanie warto�ci sygna�u steruj�cego
% o indeksie u_idx przy warto�ciach nominalnych pozosta�ych)

params = ModelParams();
if nargin < 2
    u_idx=1;
end
if nargin < 3
    threshold = 0.001;
end
u = params.u_nominal;
u_min = params.u1_min;
u_max = params.u1_max;
while u_max-u_min>threshold
    u(u_idx) = (u_max+u_min)/2;
    [~, y] = static_output(u, params);
    if y>y_stat
        u_max = (u_max+u_min)/2;
    else
        u_min = (u_max+u_min)/2;
    end
end