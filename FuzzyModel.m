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
            obj.weights = zeros(500,length(models));
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
        function y = update_local_lin(obj, u)
            obj.u(obj.k, :) = u;
            total_weight = 0;
            y = 0;
            a = zeros(10,1);
            b = zeros(10,1);
            const = 0;
            for i=1:length(obj.linear_models)
                weight = obj.membership_fun(obj.linear_models(i), obj);
                obj.weights(obj.k, i) = weight;
                total_weight = total_weight + weight;
                a = a + obj.linear_models(i).a*weight;
                b = b + obj.linear_models(i).b*weight;
                const = const + obj.linear_models(i).const*weight;
            end
            a = a/total_weight;
            b = b/total_weight;
            const = const/total_weight;
            obj.y(obj.k) = a' * obj.y(obj.k-1:-1:obj.k-10) + b * obj.u(obj.k-1:-1:obj.k-10) + const;
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
            for DEC_idx =1:length(obj.linear_models)
                obj.linear_models(DEC_idx).reset();
            end
        end
        function obj=verify(obj, model, plot)
            obj.reset();
            for k=1:model.k
                obj.update_local_lin(model.u(k,:));
            end
            
            if nargin>2 && plot
                figure;
                subplot(2,1,1);
                stairs(model.y);
                hold on;
                stairs(obj.y(1:length(model.y)));
                title('celnoœæ modelu')
                legend('rzeczywisty przebieg', 'modelowany przebieg');
                subplot(2,1,2);
                stairs(obj.weights);
                title('wartoœci wag modeli lokalnych')
            end
        end
        function obj=plot(obj)
            figure
            subplot(2,1,1);
            plot(obj.y);
            legend('setpoint', 'output', 'Location','southeast');

            subplot(2,1,2); 
            plot(obj.u(:,1));
            legend('u1');
        end
    end
end