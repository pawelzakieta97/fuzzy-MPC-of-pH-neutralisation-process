classdef Model2Params
    properties
        k1 = 50/3600;
        k2 = 100/3600;
        k3 = 10/3600;
        Caf = 10;
        Ts = 2.5;
        x_nominal = 3;
        u_nominal = 34.3/3600;
        u_max = 60/3600;
        u_min = 0;
        y_min = 0.1;
        y_max = 1.2;
        y_nominal = 1.12;
        output_delay = 4;
        subdiv = 1;
        V = 1;
    end
end