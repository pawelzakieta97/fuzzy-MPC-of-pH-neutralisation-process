function u = static_inv2(y_stat, threshold)
% funkcja zwracaj¹ca wartoœæ sygna³ów steruj¹cych u, dla których
% uzyskiwane jest wzmocnienie y_stat (szukanie wartoœci sygna³u steruj¹cego
% o indeksie u_idx przy wartoœciach nominalnych pozosta³ych)

params = Model2Params();
if nargin < 2
    threshold = 0.00001;
end
u = params.u_nominal;
u_min = params.u_min;
u_max = params.u_max;
model = Model2();
while u_max-u_min>threshold
    u = (u_max+u_min)/2;
    [~, y] = model.static_output(u);
    if y>y_stat
        u_max = (u_max+u_min)/2;
    else
        u_min = (u_max+u_min)/2;
    end
end