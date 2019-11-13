function du = expected_step(model, k)
du = model.u(k, 1)-model.u(k-1,1);