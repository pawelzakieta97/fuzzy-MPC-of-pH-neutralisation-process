function [x,y]=static_output(u, params)
    if nargin<2
        params=ModelParams();
    end
    Wa1 = params.Wa1;
    Wa2 = params.Wa2;
    Wa3 = params.Wa3;
    Wb1 = params.Wb1;
    Wb2 = params.Wb2;
    Wb3 = params.Wb3;
    x = [(u(1)*Wa1 + u(2)*Wa2 + u(3)*Wa3)/(u(1)+u(2)+u(3));...
        (u(1)*Wb1 + u(2)*Wb2 + u(3)*Wb3)/(u(1)+u(2)+u(3))];
    y = root_h(x, params.y_nominal, params);