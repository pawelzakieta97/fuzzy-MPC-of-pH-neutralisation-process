function du = expected_step(model, k)
du = model.u(k, 1)-model.u(max(k-1,1),1);
du = (model.Ysp(k)-model.Ysp(max(k-1,1)))*0.8+0.3*(model.Ysp(k-1)-model.Ysp(max(k-2,1)));