classdef DMC_FuzzyStep < DMC
    % zmodyfikowana klasa modeluj¹ca rozwa¿any obiekt, tak aby mia³a
    % liniow¹ charakterystykê statyczn¹ y_stat = u_stat
    
    properties
        controllers;
        params;
        membership_fun;
    end
    methods
        function obj=DMC_FuzzyStep(controllers, membership_fun, params)
            if nargin<3
                params = ModelParams();
            end
            obj.membership_fun = membership_fun;
            obj.params = params;
            obj.controllers = controllers;
        end
        function u = get_steering(obj, model)
            if model.k>1
                last_u = model.u(model.k-1,1);
            else
                last_u = obj.params.u1_nominal;
            end
            exp_step = obj.controllers(1).get_steering(model) - last_u;
            total_weight = 0;
            steering = 0;
            for i=1:length(obj.controllers)
                weight = obj.membership_fun(obj.controllers(i), current_model);
                obj.weights(current_model.k, i) = weight;
                total_weight = total_weight + weight;
                steering = steering + obj.controllers(i).get_steering(current_model)*weight;
            end
            obj.weights(current_model.k, :) = obj.weights(current_model.k, :)/total_weight;
            u = steering/total_weight;
        end
    end
end
            
            
            