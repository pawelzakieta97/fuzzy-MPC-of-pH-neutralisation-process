classdef FuzzyWienerModel < handle
    % klasa implementuj¹ca regulator rozmyty.
    properties
        linear_models = [];
        membership_fun;
        weights= [];
        u;
        y_in;
        y;
        k=1;
        params;
        free_responses;
        model_idx;
        y_ref;
        static_char;
        static_in_char;
%         static_output;
        static_multiplier;
    end
    methods
        function obj = FuzzyWienerModel(models, membership_fun, model_idx)
            if nargin<3
                model_idx =1;
            end
            obj.model_idx = model_idx;
            obj.params = models(1).params;
            obj.linear_models = models;
            obj.membership_fun = membership_fun;
            obj.weights = zeros(500,length(models));
            obj.y_in = ones(600,1)*obj.params.y_nominal;
            obj.y = ones(600,1)*obj.params.y_nominal;
            obj.u = repmat(obj.params.u_nominal, [500,1]);
            
            % macierz przechowywuj¹ca odpowiedŸ swobodn¹ po k próbkach w
            % k-tym wierszu
            obj.free_responses = obj.params.y_nominal*ones(501,501);
            
            
            % wyznaczanie charakterystyki statycznej modelu
            samples = 100;
            u = repmat(obj.params.u_nominal, [samples, 1]);
            u(:,1) = [1:samples]/samples*(obj.params.u_max(1)-obj.params.u_min(1))+obj.params.u_min(1);
            obj.static_char = zeros(samples,1);
            if obj.model_idx == 1
                % obj.fis = readfis('static1.fis');
                for k =1:samples
                    [~,obj.static_char(k)] = static_output(u(k,:), obj.params);
                end
            else
                m = Model2();
                for k =1:samples
                    [~,obj.static_char(k)] = m.static_output(u(k,:));
                end 
            end
            
        end
        function idx = get_static_in_idx(obj, static_in)
            [~, idx] = min(abs(obj.static_in_char-static_in));
        end
        function idx = get_static_idx(obj, static)
            [~, idx] = min(abs(obj.static_char-static));
        end
        function ys = get_static_output(obj, u)
            u_bckp = obj.u;
            y_in_bckp = obj.y_in;
            k_bckp = obj.k;
            sim_len = 200;
            obj.k = 1;
            u0 = obj.params.u_nominal;
            u0(1) = u;
            for k =1:sim_len
                obj.update_in(u0);
            end
            ys = obj.y_in(200);
            obj.reset();
        end
        function sc = generate_static_char(obj, samples)
            if nargin<2
                samples = 100;
            end
            u = [1:samples]/samples*(obj.params.u_max(1)-obj.params.u_min(1))+obj.params.u_min(1);
            obj.static_in_char = zeros(samples, 1);
            for k =1:samples
                obj.static_in_char(k) = obj.get_static_output(u(k));
                k
            end
            sc = obj.static_in_char;
        end
        
        function obj = set_sigmas(obj, sigmas)
            for i=1:length(obj.linear_models)
                obj.linear_models(i).sigma = sigmas(i);
            end
        end
        
        function y = update(obj, u)
            
            y_in = obj.update_in(u);
%             if obj.model_idx == 1
%                 [~, y] = static_output(u0, obj.params);
%             else
%                 m = Model2();
%                 [~, y] = m.static_output(u0);
%             end
            idx = obj.get_static_in_idx(y_in);
            stat_in = obj.static_in_char(idx);
            stat_out = obj.static_char(idx);
            multiplier = stat_out/stat_in;
            obj.y(obj.k) = obj.y_in(obj.k)*multiplier;
        end
        
        function y_in = update_in(obj, u)
            obj.u(obj.k, :) = u;
            total_weight = 0;
            y_in = 0;
            for i=1:length(obj.linear_models)
                window = 0;
                current_op_point = mean(obj.y_in(obj.k:obj.k+window));
                %weight = gaussmf(obj.y(obj.k), [obj.linear_models(i).sigma, obj.linear_models(i).op_point]);
                weight = gaussmf(current_op_point, [obj.linear_models(i).sigma, obj.linear_models(i).op_point]);
                obj.weights(obj.k, i) = weight;
                total_weight = total_weight + weight;
                y_in = y_in + obj.linear_models(i).update(u)*weight;
            end
            
            obj.weights(obj.k, :) = obj.weights(obj.k, :)/total_weight;
            y_in = y_in/total_weight;
            obj.k = obj.k+1;
            obj.y_in(obj.k) = y_in;
            for i=1:length(obj.linear_models)
                obj.linear_models(i).y = obj.y_in;
            end
%             u0 = obj.params.u_nominal;
%             u0(1) = y_in;
%             if obj.model_idx == 1
%                 [~, y] = static_output(u0, obj.params);
%             else
%                 m = Model2();
%                 [~, y] = m.static_output(u0);
%             end
%             obj.y(obj.k) = y;
        end
        function local_s = get_local_s(obj)
            local_s = obj.linear_models(1).s1*0;
            total_weight = 0;
            for i=1:length(obj.linear_models)
                weight = obj.membership_fun(obj.linear_models(i), obj);
                obj.weights(obj.k, i) = weight;
                total_weight = total_weight + weight;
                local_s = local_s + obj.linear_models(i).s1*weight;
            end
            local_s = local_s/total_weight;
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
                obj.update(model.u(k,:));
            end
            
            if nargin>2 && plot
                figure;
                subplot(3,1,1);
                stairs(model.y);
                hold on;
                stairs(obj.y(1:length(model.y)));
                title('celnoœæ modelu')
                legend('rzeczywisty przebieg', 'modelowany przebieg', 'Location','southeast');
                
                subplot(3,1,2);
                stairs(obj.u(:,1));
                title('przebieg wartoœci sterowania')
                
                subplot(3,1,3);
                stairs(obj.weights);
                title('wartoœci wag modeli lokalnych')
            end
        end
        function obj = copy_state(obj, real_model)
            past_samples = 3;
            obj.y = real_model.y;
            obj.u = real_model.u;
            obj.k = real_model.k;
            for i=max(1, obj.k-past_samples):obj.k
                idx = obj.get_static_idx(obj.y(i));
                stat_in = obj.static_in_char(idx);
                stat_out = obj.static_char(idx);
                multiplier = stat_in/stat_out;
                obj.y_in(i) = obj.y(i) * multiplier;
            end
            for i=1:length(obj.linear_models)
                obj.linear_models(i).k = real_model.k;
                obj.linear_models(i).y = obj.y_in;
                obj.linear_models(i).u = real_model.u(:,1);
            end
        end
        function obj=plot(obj)
            figure
            subplot(2,1,1);
            plot(obj.y);
            hold on;
            plot(obj.y_ref);
            legend('setpoint', 'output', 'Location','southeast');

            subplot(2,1,2); 
            plot(obj.u(:,1));
            legend('u1');
        end
        
        function obj = save_csv(obj, filename)
            column_names = {'t'};
            t=[1:obj.k]*obj.params.Ts;
            column_names{length(column_names)+1} = 'y';
            column_names{length(column_names)+1} = 'yref';
            
            csvwrite_with_headers(filename, [t', obj.y, obj.y_ref], column_names);
        end
    end
end