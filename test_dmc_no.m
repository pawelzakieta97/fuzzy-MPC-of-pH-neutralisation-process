N = 80;
D = 80;
Nu = 2;
wm = WienerModel(1);
Ysp = generate_setpoint();
wm.Ysp = Ysp;
dmc_no = DMC_NO(N, Nu, wm, 0.1);
model = simulation(dmc_no, Ysp,1);
