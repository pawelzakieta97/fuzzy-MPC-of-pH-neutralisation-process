function weight = normal_sp(controller, current_model)
reference_model = controller.linear_model;
weight = gaussmf(reference_model.op_point, [1,current_model.Ysp(current_model.k)]);
end