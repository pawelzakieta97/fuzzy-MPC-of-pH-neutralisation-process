% funkcja zwracaj¹ca wartoœci zmiennych stanu oraz wyjœcia, które
% ustabilizuj¹ sie przy podajen wartoœci wejœcia
function [x,y]=static_SLinear_output(u, params)
    if nargin<2
        params=ModelParams();
    end
    [x,y] = static_output(u, params);
end