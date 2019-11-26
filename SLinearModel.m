classdef SLinearModel < Model
    % zmodyfikowana klasa modelująca rozważany obiekt, tak aby miała
    % liniową charakterystykę statyczną y_stat = u_stat
    methods
        function obj=SLinearModel(Ysp, params)
            obj = obj@Model(Ysp, params);
            obj.u = obj.params.y_nominal*ones(length(Ysp),1);
        end
        function y=update(obj, y_static)
            u = static_inv(y_static, 1);
            update@Model(obj, u);
            
            % disp('SLine update');
        end
    end
end
            
            
            