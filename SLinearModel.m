classdef SLinearModel < Model
    % zmodyfikowana klasa modeluj¹ca rozwa¿any obiekt, tak aby mia³a
    % liniow¹ charakterystykê statyczn¹ y_stat = u_stat
    
    properties
        u_in;
    end
    methods
        function obj=SLinearModel(Ysp, params)
            obj = obj@Model(Ysp, params);
            obj.u_in = obj.params.y_nominal*ones(length(Ysp),1);
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
    end
end
            
            
            