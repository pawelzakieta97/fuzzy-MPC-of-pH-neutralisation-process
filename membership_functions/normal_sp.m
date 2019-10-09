function weight = normal_sp(controller, model)

weight = gaussmf(controller.op_point, [1,model.Ysp(model.k)]);
end