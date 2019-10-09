function weight = normal(controller, model)

weight = gaussmf(controller.op_point, [1,model.y(model.k)]);
end