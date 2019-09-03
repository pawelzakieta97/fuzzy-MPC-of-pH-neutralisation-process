function derivative = dx(x, u, params)
    V = params.V;
    Wa1 = params.Wa1;
    Wa2 = params.Wa2;
    Wa3 = params.Wa3;
    Wb1 = params.Wb1;
    Wb2 = params.Wb2;
    Wb3 = params.Wb3;
    f = [u(3)/V*(Wa3-x(1)); u(3)/V*(Wb3-x(2))];
    g = [u(1)/V*(Wa1-x(1)); u(1)/V*(Wb1-x(2))];
    p = [u(2)/V*(Wa2-x(1)); u(2)/V*(Wb2-x(2))];
    derivative = f+g+p;
end