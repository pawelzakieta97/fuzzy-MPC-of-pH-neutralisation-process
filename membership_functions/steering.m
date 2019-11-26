function weight = steering(reference_model, current_model)
weight = gaussmf(reference_model.op_point_u, [1,current_model.u(current_model.k, 1)]);
end