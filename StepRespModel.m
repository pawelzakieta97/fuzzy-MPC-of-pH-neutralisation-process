classdef StepRespModel < handle
    properties
        s = [];
        s1;
        s2;
        op_point;
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
    end
    methods
        function obj=StepRespModel(step_responses, step_size, params)
            if nargin<2
                obj.params = ModelParams();
            else
                obj.params = params;
            end
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
            obj.Mp1 = generateMp(1,50,obj.s(:,1));
            obj.Mp2 = generateMp(1,50,obj.s(:,2));

        end
        function y=update(obj, u)
            obj.k = obj.k + 1;
            obj.u(obj.k, :) = u;
            obj.recent_u = circshift(obj.recent_u, 1);
            obj.recent_u(1, :) = u;
            du = obj.recent_u(1:obj.D-1, :)-obj.recent_u(2:obj.D, :);
            y = obj.y(obj.k-1) + obj.Mp1*du(:,1) + obj.Mp2*du(:,2);
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
        function y_stat=static_output(obj, u)
            y_stat = obj.op_point
        end
    end
end
            
            
            