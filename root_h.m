function root = root_h(x, y0, params)
    if nargin<3
        params=ModelParams();
    end
    pK1 = params.pK1;
    pK2 = params.pK2;
    fun = @(y)h(y,x, pK1, pK2);
    root = fzero(fun, y0);