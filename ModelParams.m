classdef ModelParams < handle
    properties
        u3_nominal = 16.6;
        u2_nominal = 0.55;
        u1_nominal = 15.55;
        u_nominal = [15.55, 0.55, 16.6];
        V = 2900.0;

        x1_nominal = -0.000432;
        x2_nominal = 0.000528;
        x_nominal = [-0.000432, 0.000528];

        Wa1 = -0.00305;
        Wa2 = -0.03;
        Wa3 = 0.003;


        Wb1 = 0.00005;
        Wb2 = 0.03;
        Wb3 = 0.0;

        pK1 = 6.35;
        pK2 = 10.25;
        log10 = 2.30258509299;

        y_nominal = 7.0;
        y_max = 10.0;
        y_min = 5;

        u1_min = 0;
        u1_max = 30;

        u2_min = 0;
        u2_max = 30;

        u3_min = 10;
        u3_max = 20;

        Ts = 10;
        subdiv = 1;
    end
    methods
        function obj = randomize(obj, amplitude)
            obj.V = obj.V*((rand-0.5)*amplitude+1);
            obj.Wa1 = obj.Wa1 *((rand-0.5)*amplitude+1);
            obj.Wa2 = obj.Wa2 *((rand-0.5)*amplitude+1);
            obj.Wa3 = obj.Wa3 *((rand-0.5)*amplitude+1);
            obj.Wb1 = obj.Wb1 *((rand-0.5)*amplitude+1);
            obj.Wb2 = obj.Wb2 *((rand-0.5)*amplitude+1);
            obj.Wb3 = obj.Wb3 *((rand-0.5)*amplitude+1);
            obj.pK1 = obj.pK1 *((rand-0.5)*amplitude+1);
            obj.pK2 = obj.pK2 *((rand-0.5)*amplitude+1);
%             obj.V = obj.V*(amplitude+1);
%             obj.Wa1 = obj.Wa1 *(-amplitude+1);
%             obj.Wa2 = obj.Wa2 *(amplitude+1);
%             obj.Wa3 = obj.Wa3 *(-amplitude+1);
%             obj.Wb1 = obj.Wb1 *(amplitude+1);
%             obj.Wb2 = obj.Wb2 *(-amplitude+1);
%             obj.Wb3 = obj.Wb3 *(amplitude+1);
%             obj.pK1 = obj.pK1 *(-amplitude+1);
%             obj.pK2 = obj.pK2 *(amplitude+1);
        end
    end
end