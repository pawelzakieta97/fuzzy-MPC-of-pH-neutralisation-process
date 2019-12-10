function weight = normal(controller, current_model)
reference_model = controller.linear_model;
weight = gaussmf(current_model.y(current_model.k), [1,reference_model.op_point]);
% weight = gaussmf(controller, [1,current_model]);
end