classdef PID < handle
    % klasa implementuj¹ca regulator PID
    properties
        K=1;
        Ti=999999;
        Td=0;
        derivative=0;
        integral=0;
        prev_error=0;
        Ts;
        u1_nominal;
        integral_range=[-15,15];
    end
    methods
        function obj=PID(K, Ti, Td)
            obj.K = K;
            if nargin>1
                obj.Ti = Ti;
            end
            if nargin>2
                obj.Td = Td;
            end
            params = ModelParams();
            obj.Ts = params.Ts;
            obj.u1_nominal = params.u1_nominal;
        end
        function u=get_steering(obj, model)
            k = model.k;
            error = model.Yzad(k)-model.y(k);
            obj.integral = obj.integral+error*obj.Ts;
            obj.integral = max(min(obj.integral, obj.integral_range(2)), obj.integral_range(1));
            obj.derivative = (error-obj.prev_error)/obj.Ts;
            u = error*obj.K + obj.integral/obj.Ti + obj.derivative*obj.Td + obj.u1_nominal;
            obj.prev_error = error;
        end
    end
end
