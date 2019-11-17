function weight = normal_sp(reference_model, current_model)

weight = gaussmf(reference_model.op_point, [1,current_model.Ysp(current_model.k)]);
end