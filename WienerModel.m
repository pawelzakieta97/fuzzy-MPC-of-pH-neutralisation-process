classdef WienerModel < StepRespModel
    % klasa implementuj¹ca regulator rozmyty.
    properties
        y_in;
        M1;
        M2;
        Ysp;
    end
    methods
        function obj = WienerModel(params)
            if nargin<1
                params = ModelParams();
            end
            [~,s,~] = step(params.u_nominal, 0.1, 80);
            amp = s(length(s))-s(1);
            obj = obj@StepRespModel(s, amp, params);
            obj.y_in = obj.params.u1_nominal *ones(500,1);
        end
        function y = update(obj, u)
            obj.u(obj.k, :) = u;
            obj.k = obj.k + 1;
            up = obj.get_up(obj.D);
            du = up(1:obj.D-1, :)-up(2:obj.D, :);
            s1 = obj.s1(1:obj.D-1);
            s2 = obj.s2(1:obj.D-1);
            y_in = up(obj.D, 1)+s1'*du(:,1) + s2'*du(:,2);
            % y_in = obj.y_in(obj.k-1) + obj.Mp1*du(:,1) + obj.Mp2*du(:,2);
            obj.y_in(obj.k) = y_in;
            u0 = obj.params.u_nominal;
            u0(1) = y_in;
            [~, y] = static_output(u0, obj.params);
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