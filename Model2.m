classdef Model2 < handle
    properties
        x = zeros(1000,2);
        y = zeros(1000,1);
        u = zeros(1000,1);
        k=1;
        Ysp = [];
        params;
    end
    methods
        function obj=Model2(Ysp, params)
            if nargin<2
                obj.params = Model2Params();
            else
                obj.params = params;
            end
            samples = 500;
            if nargin>0
                obj.Ysp = Ysp;
                samples = length(Ysp);
            end
            obj.x = repmat(obj.params.x_nominal, [samples,1]);
            obj.y = ones(samples,1)*obj.params.y_nominal;
            obj.u = repmat(obj.params.u_nominal, [samples,1]);
            obj.k=1;
            
        end
        function y=update(obj, u)
            for j=1:size(u,1)
                obj.u(obj.k) = u(j);

                % obliczenie nowej wartoœci zmiennych stanu za pomoc¹ metody
                % Eulera. Zmienna subdiv zwiêksza rozdzielczoœæ symulacji
                % wzglêdem okresu próbkowania
                obj.x(obj.k+1) = obj.x(obj.k);
                obj.y(obj.k+1) = obj.y(obj.k);
                u_time = obj.k-obj.params.output_delay;
                if u_time <1
                    u_update = obj.params.u_nominal;
                else
                    u_update = obj.u(u_time);
                end
                for i=1:obj.params.subdiv
                    dx = -obj.params.k1*obj.x(obj.k+1)-...
                        obj.params.k3*(obj.x(obj.k+1))^2 +...
                        u_update/obj.params.V*(obj.params.Caf-obj.x(obj.k+1));
                
                    dy = obj.params.k1*obj.x(obj.k+1)-...
                        obj.params.k2*obj.y(obj.k+1)-...
                        u_update/obj.params.V*obj.y(obj.k+1);
                    
                    obj.x(obj.k+1) = obj.x(obj.k+1)+dx*obj.params.Ts;
                    obj.y(obj.k+1) = obj.y(obj.k+1)+dy*obj.params.Ts;
                end
                obj.k = obj.k+1;
            end
        end
        function [x,y] = static_output(obj, u)
            k1 = obj.params.k1;
            k2 = obj.params.k2;
            k3 = obj.params.k3;
            V = obj.params.V;
            Caf = obj.params.Caf;
            if (k1+u/V)^2+4*k3*u*Caf/V<0
                x = (-k1-u/V)/2/k3;
            else
                x = (-k1-u/V+sqrt((k1+u/V)^2+4*k3*u*Caf/V))/2/k3;
            end
            y = k1*x/(k2+u/V);
        end
        function [u,y] = static_char(obj, samples)
            u_min = obj.params.u_min;
            u_max = obj.params.u_max;
            u = zeros(samples, 1);
            y = zeros(samples, 1);
            for i=1:samples
                u(i) = u_min + (u_max-u_min)/samples*i;
                [~, y(i)] = obj.static_output(u(i));
            end
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
        function obj=plot(obj)
            figure
            subplot(2,1,1);
            stairs(obj.Ysp, '--');
            hold on;
            plot(obj.y(1:length(obj.Ysp)));
            legend('setpoint', 'output', 'Location','southeast');
            xlabel('t');
            hold off;

            subplot(2,1,2); 
            stairs(obj.u(:,1));
            legend('u1');
            xlabel('t');
        end
        function obj=plot_horizontal(obj)
            figure
            subplot(1,2,1);
            stairs(obj.Ysp, '--');
            hold on;
            plot(obj.y(1:length(obj.Ysp)));
            legend('setpoint', 'output', 'Location','southeast');
            hold off;

            subplot(1,2,2); 
            stairs(obj.u(:,1));
            legend('u1');
        end
        function obj = copy_state(obj, reference_model)
            obj.x = reference_model.x;
            obj.y = reference_model.y;
            obj.u = reference_model.u;
            obj.k = reference_model.k;
            
        end
        
        function obj = save_csv(obj, filename)
            column_names = {};
            for u_idx = 1:size(obj.u,2)
                column_names{u_idx} = ['u', num2str(u_idx)];
            end
            column_names{length(column_names)+1} = 'y';
            column_names{length(column_names)+1} = 'ysp';
            csvwrite_with_headers(filename, [obj.u, obj.y, obj.Ysp], column_names);
        end
    end
end
            
            
            