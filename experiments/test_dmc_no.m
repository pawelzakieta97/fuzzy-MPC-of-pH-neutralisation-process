addpath('../');
N = 80;
D = 80;
Nu = 2;
wm = WienerModel(1);
Ysp = generate_setpoint();
wm.Ysp = Ysp;
Ysp = [5*ones(30,1); 8*ones(40,1); 4.5*ones(30,1)];
dmc_no = DMC_NO(N, Nu, wm, 0.1);

model_no_wm = simulation(dmc_no, Ysp,1);
model_no_wm.save_csv('../wykresy/ph/no_wiener.csv');

dmc_no = DMC_NO(N, Nu, Model(Ysp), 0.1);
model_no_real = simulation(dmc_no, Ysp,1);
model_no_real.save_csv('../wykresy/ph/no_real.csv');