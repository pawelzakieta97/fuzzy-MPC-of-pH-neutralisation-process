addpath('../');
wm = WienerModel(2);
wm.static_char;
samples = length(wm.static_char);
u = [1:samples]/samples*(wm.params.u_max(1)-wm.params.u_min(1))+wm.params.u_min(1);
plot(u,wm.static_char);
csvwrite_with_headers('../wykresy/vdv/static.csv', [u'*3600, wm.static_char], {'u','y'});