% funkcja zwracaj�ca warto�ci zmiennych stanu oraz wyj�cia, kt�re
% ustabilizuj� sie przy podajen warto�ci wej�cia
function [x,y]=static_SLinear_output(u, params)
    if nargin<2
        params=ModelParams();
    end
    [x,y] = static_output(u, params);
end