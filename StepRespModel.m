classdef StepRespModel < handle
    properties
        s = [];
        s1;
        s2;
        op_point;
        u0;
        step_size;
        params;
        k=1;
        y;
        u;
        D = 80;
        recent_u;
        Mp1; 
        Mp2;
        amplification;
        sigma = 1;
    end
    methods
        function obj=StepRespModel(step_responses, step_size, u0, params)
            if nargin<2
                obj.params = ModelParams();
            else
                obj.params = params;
            end
            obj.u0 = u0;
            obj.op_point = step_responses(1,1);
            obj.step_size = step_size;
            obj.amplification = (step_responses(length(step_responses), 1) - step_responses(1,1))/obj.step_size;
            if size(step_responses, 2) == 1
                step_responses = [step_responses, step_responses*0];
            end
            obj.s = (step_responses(2:end, :)-step_responses(1, :))/obj.step_size;
            obj.s1 = obj.s(:,1);
            obj.s2 = obj.s(:,2);
            obj.y = ones(500,1)*obj.params.y_nominal;
            obj.u = repmat(obj.params.u_nominal, [500,1]);
            obj.recent_u = repmat(obj.params.u_nominal, [obj.D,1]);
            obj.Mp1 = generateMp(1,obj.D,obj.s(:,1));
            obj.Mp2 = generateMp(1,obj.D,obj.s(:,2));

        end
        function y=update1(obj, u)
            obj.u(obj.k, :) = u;
            obj.k = obj.k + 1;
            obj.recent_u = circshift(obj.recent_u, 1);
            obj.recent_u(1, :) = u;
            du = obj.recent_u(1:obj.D-1, :)-obj.recent_u(2:obj.D, :);
            up = obj.get_up(obj.D);
            du = up(1:obj.D-1, :)-up(2:obj.D, :);
            y = obj.y(obj.k-1) + obj.Mp1*du(:,1) + obj.Mp2*du(:,2);
            obj.y(obj.k) = y;
        end
        function y=update(obj, u)
            obj.u(obj.k, :) = u;
            obj.k = obj.k + 1;
            du = obj.recent_u(1:obj.D-1, :)-obj.recent_u(2:obj.D, :);
            up = obj.get_up(obj.D);
            du = up(1:obj.D-1, :)-up(2:obj.D, :);
            y = obj.op_point+(up(obj.D,1)-obj.u0(1))*obj.s1(obj.D)+...
                obj.s1(1:obj.D-1)'*du(:,1);
            obj.y(obj.k) = y;
        end
        function obj = reset(obj)
            obj.k = 1;
            obj.y = ones(500,1)*obj.params.y_nominal;
            obj.u = repmat(obj.params.u_nominal, [500,1]);
        end
        function obj=verify(obj, model, plot)
            obj.reset();
            for k=1:model.k
                obj.update(model.u(k,:));
            end
            
            if nargin>3 && plot
                stairs(obj.y);
                hold on;
                stairs(model.y);
            end
        end
        function obj=plot(obj)
            figure
            subplot(2,1,1);
            plot(obj.y(1:obj.k));
            legend('setpoint', 'output', 'Location','southeast');
            hold off;

            subplot(2,1,2); 
            plot(obj.u(:,1));
            legend('u1');
        end
        function obj=plot_horizontal(obj)
            figure
            subplot(1,2,1);
            plot(obj.y(1:obj.k));
            legend('setpoint', 'output', 'Location','southeast');
            hold off;

            subplot(1,2,2); 
            plot(obj.u(:,1));
            legend('u1');
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
    end
end
            
            
            