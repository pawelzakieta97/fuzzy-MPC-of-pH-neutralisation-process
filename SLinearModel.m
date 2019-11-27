classdef SLinearModel < Model
    % zmodyfikowana klasa modeluj�ca rozwa�any obiekt, tak aby mia�a
    % liniow� charakterystyk� statyczn� y_stat = u_stat
    
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
            % zwraca warto�ci przesz�ych sterowa�
            % (w kolejno�ci od najpo�niejszego do najwcze�niejszego)
            % zwraca D warto�ci, uzupe�nia warto�ciami
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
            
            
            