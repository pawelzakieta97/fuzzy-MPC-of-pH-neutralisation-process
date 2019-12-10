function weight = output_and_step_size(controller, model, exp_step)

weight = gaussmf(model.y(model.k), [1, controller.linear_model.op_point])*...
    gaussmf(exp_step, [1,controller.linear_model.step_size]);