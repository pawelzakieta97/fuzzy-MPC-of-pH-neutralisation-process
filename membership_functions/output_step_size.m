function weight = output_step_size(controller, model)

weight = gaussmf(model.y(model.k), [1, controller.op_point])*...
    gaussmf(expected_step(controller, model, model.k), [1,controller.step_size]);