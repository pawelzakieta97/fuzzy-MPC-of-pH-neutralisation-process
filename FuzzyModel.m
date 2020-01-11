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
        free_responses;
        model_idx;
%         static_output;
    end
    methods
        function obj = FuzzyModel(models, membership_fun, model_idx)
            if nargin<3
                model_idx =1;
            end
            if model_idx == 1
                params = ModelParams();
            else
                params = Model2Params();
            end
            obj.model_idx = model_idx;
            obj.params = models(1).params;
            obj.linear_models = models;
            obj.membership_fun = membership_fun;
            obj.weights = zeros(500,length(models));
            obj.y = ones(600,1)*obj.params.y_nominal;
            obj.u = repmat(obj.params.u_nominal, [500,1]);
            
            % macierz przechowywuj¹ca odpowiedŸ swobodn¹ po k próbkach w
            % k-tym wierszu
            obj.free_responses = obj.params.y_nominal*ones(501,501);
            
        end
        
        function obj = set_sigmas(obj, sigmas)
            for i=1:length(obj.linear_models)
                obj.linear_models(i).sigma = sigmas(i);
            end
        end
        
        function y = update1(obj, u)
            obj.u(obj.k, :) = u;
            total_weight = 0;
            y = 0;
            for i=1:length(obj.linear_models)
                weight = gaussmf(obj.y(obj.k), [obj.linear_models(i).sigma, obj.linear_models(i).op_point]);
                obj.weights(obj.k, i) = weight;
                total_weight = total_weight + weight;
                y = y + obj.linear_models(i).update(u)*weight;
            end
            obj.weights(obj.k, :) = obj.weights(obj.k, :)/total_weight;
            y = y/total_weight;
            obj.k = obj.k+1;
            obj.y(obj.k) = y;
        end
        
        function y = update_custom(obj, u)
            sim_len = 501;
            D = 50;
            obj.u(obj.k, :) = u;
            local_s = obj.linear_models(1).s*0;
            total_weight = 0;
            for i=1:length(obj.linear_models)
                weight = obj.membership_fun(obj.linear_models(i), obj);
                obj.weights(obj.k, i) = weight;
                total_weight = total_weight + weight;
                local_s = local_s + obj.linear_models(i).s*weight;
            end
            local_s = local_s/total_weight;
            obj.k = obj.k+1;
            if obj.k > 2
                du = obj.u(obj.k-1,1) - obj.u(obj.k-2,1);
            else
                du = obj.u(1)-obj.params.u1_nominal;
            end
            this_step = local_s(1:D)*du;
            this_step = [this_step; this_step(D)*ones(sim_len,1)];
            obj.free_responses(obj.k, obj.k:sim_len) = obj.free_responses(obj.k-1,obj.k:sim_len)+...
                this_step(1:sim_len-obj.k+1)';
            
            static_y = obj.params.y_nominal;
            first_sample = max(1, obj.k-D+1);
            [~, static_y] = static_output(obj.u(first_sample,:));
            
            free_response = obj.free_responses(obj.k, obj.k) - obj.free_responses(first_sample, obj.k);
            y = static_y + free_response;
            obj.y(obj.k) = y;
                
        end
        
        function y=updateML(obj, u)
            D = 50;
            if obj.k==217
                a=10;
            end
            obj.u(obj.k, :) = u;
            local_s = obj.linear_models(1).s*0;
            total_weight = 0;
            for i=1:length(obj.linear_models)
                % weight = obj.membership_fun(obj.linear_models(i), obj);
                weight = gaussmf(obj.y(obj.k), [1, obj.linear_models(i).op_point]);
                obj.weights(obj.k, i) = weight;
                total_weight = total_weight + weight;
                local_s = local_s + obj.linear_models(i).s*weight;
            end
            local_s = local_s/total_weight;
            obj.weights(obj.k,:) = obj.weights(obj.k,:)/total_weight;
            step_len = length(local_s);
            obj.k = obj.k+1;
            remaining = length(obj.y) - obj.k;
            
            if obj.k > 2
                du = obj.u(obj.k-1,1) - obj.u(obj.k-2,1);
            else
                du = obj.u(1)-obj.params.u1_nominal;
            end
            k_filter = 0.1;
            [~, y0] = static_output(obj.u(min(max(1,obj.k),500), :));
            obj.y(obj.k:obj.k+D-1) = obj.y(obj.k:obj.k+D-1) + local_s(1:D)*du;
            
            obj.y(obj.k+D:length(obj.y)) = obj.y(obj.k+D:length(obj.y))...
                + local_s(step_len)*ones(remaining-D+1, 1)*du;
            
%             obj.y(obj.k:length(obj.y)) = obj.y(obj.k:length(obj.y)) + k_filter*(y0-obj.y(obj.k));
%             [~, y0] = static_output(obj.u(max(1,obj.k-D), :));
%             obj.y(max(1,obj.k):length(obj.y)) = obj.y(max(1,obj.k):length(obj.y))...
%                 + y0 - obj.y(max(1,obj.k-D));
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
        function update(obj, u)
            obj.u(obj.k, :) = u;
            local_s = obj.linear_models(1).s*0;
            total_weight = 0;
            D = 80;
            for i=1:length(obj.linear_models)
                % weight = obj.membership_fun(obj.linear_models(i), obj);
                y_mean = mean(obj.y(max(obj.k-D,1):obj.k));
                weight = gaussmf(obj.y(obj.k), [obj.linear_models(i).sigma, obj.linear_models(i).op_point]);
                % weight = gaussmf(y_mean, [1, obj.linear_models(i).op_point]);
                obj.weights(obj.k, i) = weight;
                total_weight = total_weight + weight;
                local_s = local_s + obj.linear_models(i).s*weight;
            end
            obj.weights(obj.k,:) = obj.weights(obj.k,:)/total_weight;
            local_s = local_s/total_weight;
            Mp = generateMp(1, D, local_s);
%             M = generateM(1, D-1, D, local_s);
            obj.k = obj.k+1;
            up = obj.get_up(D);
            dup = up(1:D-1,1) - up(2:D,1);
            
            if obj.model_idx == 1
                [~, static_y] = static_output(up(D,:));
                [~, static_y1] = static_output(up(1,:));
            else
                [~, static_y] = static_output2(up(D,:));
                [~, static_y1] = static_output2(up(1,:));
            end
            local_s = local_s';
            
            y1 = obj.y(obj.k-1)+Mp*dup;
            k = 0.01;
            k = 0;
            
            obj.y(obj.k) = (1-k)*y1 + k*static_y1;
            % obj.y(obj.k) = static_y + local_s(1:length(dup))*dup;
        end
        function up = get_up(obj, length)
            % zwraca wartoœci przesz³ych sterowañ
            % (w kolejnoœci od najpoŸniejszego do najwczeœniejszego)
            % zwraca D wartoœci, uzupe³nia wartoœciami
            % nominalnymi
            if obj.k == 1
                up = repmat(obj.params.u_nominal, [length,1]);
            else
                up = obj.u(obj.k-1:-1:1, :);
                up = [up;repmat(obj.params.u_nominal, [length,1])];
                up = up(1:length,:);
            end
        end
        function obj = reset(obj)
            obj.k = 1;
            obj.weights = obj.weights * 0;
            obj.y = ones(600,1)*obj.params.y_nominal;
            obj.u = repmat(obj.params.u_nominal, [500,1]);
            for DEC_idx =1:length(obj.linear_models)
                obj.linear_models(DEC_idx).reset();
            end
        end
        function obj=verify(obj, model, plot)
            obj.reset();
            for k=1:model.k
                %obj.update_local_lin(model.u(k,:));
                %obj.updateML(model.u(k,:));
                % obj.update_custom(model.u(k,:));
                obj.update1(model.u(k,:));
            end
            
            if nargin>2 && plot
                figure;
                subplot(3,1,1);
                stairs(model.y);
                hold on;
                stairs(obj.y(1:length(model.y)));
                title('celnoœæ modelu')
                legend('rzeczywisty przebieg', 'modelowany przebieg');
                
                subplot(3,1,2);
                stairs(obj.u(:,1));
                title('przebieg wartoœci sterowania')
                
                subplot(3,1,3);
                stairs(obj.weights);
                title('wartoœci wag modeli lokalnych')
            end
        end
        function obj = copy_state(obj, real_model)
            obj.y = real_model.y;
            obj.u = real_model.u;
            obj.k = real_model.k;
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