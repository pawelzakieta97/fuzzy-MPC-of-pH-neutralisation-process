classdef DMC_NO < handle
    % klasa reprezentuj¹ca regulator minimalizuj¹cy rzeczywist¹ funkcjê
    % kosztu na prawdziwym modelu
    properties
        N
        Nu = 5;
        params;
        output_limit = [0,0];
        limit_output = 0;
        sim_model;
        main_model;
        lower_bandwidth = 0.0;
        upper_bandwidth = 0.0;
        lambda;
        planned_steering;
    end
    methods
        function obj=DMC_NO(N, Nu, model, lambda)
            obj.params = ModelParams();
            obj.sim_model = model;
            obj.N = N;
            obj.Nu = Nu;
            obj.lambda = lambda;
            if nargin>7
                obj.output_limit = output_limit;
            else
                obj.output_limit = [0,0];
            end
            obj.planned_steering = obj.params.u_nominal(1)*ones(Nu,1);
        end
        function u_new = get_steering(obj, current_model)
            up = current_model.get_up(1);
            init_u1 = obj.planned_steering;
            %obj.sim_model.copy_state(current_model);
            obj.sim_model.set_k(current_model.k);
            d = current_model.y(current_model.k) - obj.sim_model.y(obj.sim_model.k);
            [steering, error] = fmincon(...
            @(u)get_cost(u, obj.N, obj.sim_model, obj.lambda, current_model.k, d), init_u1,...
            -eye(obj.Nu), zeros(obj.Nu,1));
            obj.sim_model.set_k(current_model.k);
            u_new = steering(1,1);
            obj.planned_steering = [steering(2:obj.Nu); steering(obj.Nu)];
            
            u0 = obj.sim_model.params.u_nominal;
            u0(1) = min(max(u_new, obj.params.u_min(1)), obj.params.u_max(1));
            obj.sim_model.update(u0);
            current_model.k
        end
    end
end
        