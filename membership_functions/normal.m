function weight = normal(reference_model, current_model)

weight = gaussmf(reference_model.op_point, [1,current_model.y(current_model.k)]);
end