function der = dh(y,x)
    num = 1 + 2*pow(10, (y-pK2));
    den = 1 + 10*(pK1-y) + pow(10, (y-pK2));
    der = 100*log10 * (pow(10, y-14)+...
        pow(10, -y)) + x(2)*(log10*2*pow(10, y-pK2)*den -...
        log10*(pow(10, y-pK2)-pow(10, pK1-y))*num)/den/den;
end