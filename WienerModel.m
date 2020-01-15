classdef WienerModel < StepRespModel
    % klasa implementuj¹ca regulator rozmyty.
    properties
        y_in;
        M1;
        M2;
        Ysp;
        static_output;
        static_inv;
        model_idx;
        static_char;
        y_ref;
    end
    methods
        function obj = WienerModel(model_idx, params)
            
            if model_idx == 1 || nargin<1
                model_idx = 1;
                step_size = 0.01;
                if nargin<2
                    params = ModelParams();
                end
            else
                if model_idx == 2
                    step_size = 0.001;
                    if nargin<2
                        params = Model2Params();
                    end
                end
            end
            [~,s,~] = step(params.u_nominal, step_size, 80, model_idx);
            amp = s(length(s))-s(1);
            obj = obj@StepRespModel(s, amp, params.u_nominal, params);
            obj.y_in = obj.params.u_nominal(1) *ones(500,1);
            obj.model_idx = model_idx;
            % wyznaczanie charakterystyki statycznej
            samples = 1000;
            u = repmat(params.u_nominal, [samples, 1]);
            u(:,1) = [1:samples]/samples*(params.u_max(1)-params.u_min(1))+params.u_min(1);
            obj.static_char = zeros(samples,1);
            if obj.model_idx == 1
                for k =1:samples
                    [~,obj.static_char(k)] = static_output(u(k,:), params);
                end
            else
                m = Model2();
                for k =1:samples
                    [~,obj.static_char(k)] = m.static_output(u(k,:));
                end 
            end
        end
        function i=get_static_char_idx(obj, y_s)
            [~,i] = min(abs(obj.static_char-y_s));
        end
        function y = update(obj, u)
            obj.u(obj.k, :) = u;
            obj.k = obj.k + 1;
            up = obj.get_up(obj.D);
            du = up(1:obj.D-1, :)-up(2:obj.D, :);
            s1 = obj.s1(1:obj.D-1);
            % s2 = obj.s2(1:obj.D-1);
            y_in = up(obj.D, 1)+s1'*du(:,1);%  + s2'*du(:,2);
            % y_in = obj.y_in(obj.k-1) + obj.Mp1*du(:,1) + obj.Mp2*du(:,2);
            obj.y_in(obj.k) = y_in;
            u0 = obj.params.u_nominal;
            u0(1) = y_in;
            if obj.model_idx == 1
                [~, y] = static_output(u0, obj.params);
            else
                m = Model2();
                [~, y] = m.static_output(u0);
            end
            obj.y(obj.k) = y;
        end
        function obj=verify(obj, model, plot, file_name)
            obj.reset();
            for k=1:model.k
                %obj.update_local_lin(model.u(k,:));
                %obj.updateML(model.u(k,:));
                % obj.update_custom(model.u(k,:));
                obj.update(model.u(k,:));
            end
            
            if nargin>2 && plot
                figure;
                subplot(2,1,1);
                stairs(model.y);
                hold on;
                stairs(obj.y(1:length(model.y)), '--');
                title('celnoœæ modelu')
                legend('rzeczywisty przebieg', 'modelowany przebieg', 'location', 'southeast');
                
                subplot(2,1,2);
                stairs(obj.u(:,1));
                title('przebieg wartoœci sterowania')
            end
            if nargin>3
                column_names = {'t', 'y', 'yref'};
                t=[1:obj.k-1]*model.params.Ts;
                csvwrite_with_headers(file_name, [t', obj.y(1:obj.k-1), model.y], column_names);
            end
        end
        function local_s = get_local_s(obj)
            samples = length(obj.static_char);
            du = (obj.params.u_max(1)-obj.params.u_min(1))/samples;
            idx = obj.get_static_char_idx(obj.y(obj.k));
            dy = obj.static_char(idx+1) - obj.static_char(idx);
            local_s = obj.s1*dy/du;
        end
        function obj = copy_state(obj, real_model)
            obj.y = real_model.y;
            obj.u = real_model.u;
            obj.k = real_model.k;
            obj.Ysp = real_model.Ysp;
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
        function wm = clone(obj)
            wm = WienerModel(obj.model_idx);
            wm.copy_state(obj);
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