function weight = normal(controller, current_model)
if isa(controller, 'StepRespModel') || isa(controller, 'DiffEqModel')
    reference_model = controller;
else
    reference_model = controller.linear_model;
end
weight = gaussmf(current_model.y(current_model.k), [reference_model.sigma ,reference_model.op_point]);
% weight = gaussmf(controller, [1,current_model]);
end