function [x,y] = static_output2(u, params)
if nargin<2
    params = Model2Params();
end
k1 = params.k1;
k2 = params.k2;
k3 = params.k3;
V = params.V;
Caf = params.Caf;
if (k1+u/V)^2+4*k3*u*Caf/V<0
    x = (-k1-u/V)/2/k3;
else
    x = (-k1-u/V+sqrt((k1+u/V)^2+4*k3*u*Caf/V))/2/k3;
end
y = k1*x/(k2+u/V);
end