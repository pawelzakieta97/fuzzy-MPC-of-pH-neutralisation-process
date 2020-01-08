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
    end
    methods
        function obj = WienerModel(model_idx, params)
            
            if model_idx == 1 || nargin<1
                model_idx = 1;
                step_size = 0.1;
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
            obj = obj@StepRespModel(s, amp, params);
            obj.y_in = obj.params.u_nominal(1) *ones(500,1);
            obj.model_idx = model_idx;
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
            wm = WienerModel();
            wm.copy_state(obj);
        end
    end
end