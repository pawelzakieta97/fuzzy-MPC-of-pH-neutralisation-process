function du = expected_step(controller, model, k)
multiplier = 0.3;
du = multiplier * (model.Ysp(k)-model.y(k))^2*sign(model.Ysp(k)-model.y(k))/controller.lambda^0.5;