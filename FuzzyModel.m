classdef FuzzyModel < handle
    % klasa implementuj¹ca regulator rozmyty.
    properties
        linear_models = [];
        membership_fun;
        weights= [];
        u;
        y;
        k=1;
        params;
    end
    methods
        function obj = FuzzyModel(models, membership_fun, params)
            if nargin<3
                params = ModelParams();
            end
            obj.params = params;
            obj.linear_models = models;
            obj.membership_fun = membership_fun;
            obj.weights = zeros(1000,length(models));
            obj.y = ones(500,1)*obj.params.y_nominal;
            obj.u = repmat(obj.params.u_nominal, [500,1]);
        end
        function y = update(obj, u)
            obj.u(obj.k, :) = u;
            total_weight = 0;
            y = 0;
            for i=1:length(obj.linear_models)
                weight = obj.membership_fun(obj.linear_models(i), obj);
                obj.weights(obj.k, i) = weight;
                total_weight = total_weight + weight;
                y = y + obj.linear_models(i).update(u)*weight;
            end
            obj.weights(obj.k, :) = obj.weights(obj.k, :)/total_weight;
            y = y/total_weight;
            obj.k = obj.k+1;
            obj.y(obj.k) = y;
        end
        function obj = reset(obj)
            obj.k = 1;
            obj.weights = obj.weights * 0;
            obj.y = ones(500,1)*obj.params.y_nominal;
            obj.u = repmat(obj.params.u_nominal, [500,1]);
        end
        function obj=verify(obj, model, plot)
            obj.reset();
            for k=1:model.k
                obj.update(model.u(k,:));
            end
            
            if nargin>2 && plot
                stairs(obj.y);
                hold on;
                stairs(model.y);
            end
        end
    end
end