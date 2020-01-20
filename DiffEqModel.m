classdef DiffEqModel < handle
    properties
        s1;
        %s = [];
        op_point;
        op_point_u;
        params;
        a;
        b;
        const;
        k=1;
        y;
        u;
        na;
        nb;
        D = 80;
        Mp1; 
        Mp2;
        model_idx;
        sigma;
        slopel;
        liml;
        limr;
        sloper;
    end
    methods
        function obj=DiffEqModel(u,y,nb,na, params, init)
            if nargin <6
                init = 1;
            end
            if init
                if nargin<5
                    params = ModelParams();
                end
                obj.params = params;
                obj.op_point = mean(y);
                obj.op_point_u = mean(u);
                obj.nb = nb;
                obj.na = na;
                u = u(1:min(length(u), length(y)));
                y = y(1:min(length(u), length(y)));
                y = y(1+obj.params.output_delay:end);
                u = u(1:length(y));
                sim_len = length(u);
                M = zeros(sim_len, na+nb+1);
                for k=max(nb, na)+1:sim_len
                    y_row = y(k-1:-1:k-na);
                    u_row = u(k-1:-1:k-nb);
                    M(k,:)=[y_row', u_row', 1];
                end

                M = M(max(na, nb)+1:end, :);
                y_real = y(max(na, nb)+1:end);
                w=(M'*M)^(-1)*M'*y_real;
                obj.a = w(1:na);
                obj.b = w(na+1:na+nb);
                obj.const = w(na+nb+1);
                obj.y = obj.params.y_nominal*ones(500,1);
                obj.u = obj.params.u_nominal(1)*ones(500,1);
                %obj.s = obj.step(100);
                obj.s1 = obj.step(100);
            end
        end
        function dem2 = clone(obj)
            dem2 = DiffEqModel(1,1,1,1, 1, 0);
            dem2.params = obj.params;
            dem2.a = obj.a;
            dem2.b = obj.b;
            dem2.const = obj.const;
            dem2.y = obj.y;
            dem2.u = obj.u;
            dem2.k = obj.k;
            dem2.na = obj.na;
            dem2.nb = obj.nb;
            dem2.D = obj.D;
            dem2.Mp1 = obj.Mp1;
            dem2.Mp2 = obj.Mp2;
            dem2.op_point = obj.op_point;
            dem2.op_point_u = obj.op_point_u;
            dem2.sigma = obj.sigma;
        end
        function y=update(obj, u)
            obj.u(obj.k) = u(1);
            yp = obj.get_yp(obj.na);
            if obj.k == 252
                a=1
            end
            obj.k = obj.k+1;
            
            up = obj.get_up(obj.nb+obj.params.output_delay);
            up = up(obj.params.output_delay+1:end);
            %obj.y(obj.k) = obj.a' * obj.y(obj.k-1:-1:obj.k-obj.na) + obj.b * obj.u(obj.k-1:-1:obj.k-obj.nb) + obj.const;
            
            obj.y(obj.k) = obj.a' * yp + obj.b' * up + obj.const;
            y = obj.y(obj.k);
        end
        function up = get_up(obj, length)
            if obj.k == 1
                up = repmat(obj.params.u_nominal, [length,1]);
            else
                up = obj.u(obj.k-1:-1:1, :);
                up = [up;repmat(obj.params.u_nominal(1), [length,1])];
                up = up(1:length,:);
            end
        end
        function yp = get_yp(obj, length)
            if obj.k == 1
                yp = repmat(obj.params.y_nominal, [length,1]);
            else
                yp = obj.y(obj.k:-1:1);
                yp = [yp;repmat(obj.params.y_nominal, [length,1])];
                yp = yp(1:length,:);
            end
        end
        function obj = reset(obj)
            obj.k = 1;
            obj.y = obj.params.y_nominal*ones(500,1);
            obj.u = obj.params.u_nominal(1)*ones(500,1);
        end
        function obj=verify(obj, model, plot)
            obj.reset();
            for k=1:model.k-1
                obj.update(model.u(k,1));
            end
            
            if nargin>2 && plot
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
            y_stat = (u*sum(obj.b)+obj.const)/(1-sum(obj.a));
        end
        function u_stat = static_steering(obj, y)
            u_stat = ((1-sum(obj.a))*y-obj.const)/sum(obj.b);
        end
        function s = step(obj, samples)
            if nargin<2
                samples = 100;
            end
            obj.reset();
            obj.y(1) = obj.op_point;
            u0 = obj.static_steering(obj.op_point);
            for k=1:samples
                obj.update(u0+1);
            end
            s = obj.y(1:samples);
            s = s-s(1);
        end
    end
end
            
            
            