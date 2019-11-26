function weight = output_steering(reference_model, current_model)
weight = steering(reference_model, current_model) * normal(reference_model, current_model);
end