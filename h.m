function res = h(y, x, pK1, pK2)
    res = x(1) + 10^(y-14)-10^(-y)+x(2)*(1+2*10^(y-pK2))/...
        (1+10^(pK1-y)+10^(y-pK2));
end
    