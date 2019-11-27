classdef SLinearModel < Model
    % zmodyfikowana klasa modeluj¹ca rozwa¿any obiekt, tak aby mia³a
    % liniow¹ charakterystykê statyczn¹ y_stat = u_stat
    
    properties
        u_in;
        u_in_min;
        u_in_max;
    end
    methods
        function obj=SLinearModel(Ysp, params)
            if nargin<2
                params = ModelParams();
            end
            obj = obj@Model(Ysp, params);
            obj.u_in = obj.params.y_nominal*ones(length(Ysp),1);
            [~, y_min] = static_output([obj.params.u1_min, obj.params.u2_nominal, obj.params.u3_nominal]);
            [~, y_max] = static_output([obj.params.u1_max, obj.params.u2_nominal, obj.params.u3_nominal]);
            obj.u_in_min = y_min;
            obj.u_in_max = y_max;
        end
        function y = update(obj, u_in)
            obj.u_in(obj.k) = u_in;
            y_static = u_in;
            u = static_inv(y_static, 1);
            update@Model(obj, u);
            y = obj.y(obj.k);
            % disp('SLine update');
        end
        function up = get_up(obj, length)
            % zwraca wartoœci przesz³ych sterowañ
            % (w kolejnoœci od najpoŸniejszego do najwczeœniejszego)
            % zwraca D wartoœci, uzupe³nia wartoœciami
            % nominalnymi
            if obj.k == 1
                up = repmat(obj.u_in(1), [length,1]);
            else
                up = obj.u_in(obj.k-1:-1:1);
                up = [up;repmat(up(size(up,1)), [length,1])];
                up = up(1:length);
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
            stairs(obj.u_in);
            legend('u_{in}');
            xlabel('t');
        end
    end
end
            
            
            