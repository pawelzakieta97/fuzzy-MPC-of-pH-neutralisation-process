function overshoot = get_overshoot(Ysp, y)
overshoot = Ysp*0;
overshooting = false;
max_overshoot = 0;
max_overshoot_idx = 1;
for k=2:length(Ysp)
    if Ysp(k) == Ysp(k-1)
        if (y(k)-Ysp(k)) * (y(k-1)-Ysp(k-1))<0
            overshooting = true;
            
        end
        if overshooting
            if abs(y(k)-Ysp(k))>max_overshoot
                overshoot(k) = abs(y(k)-Ysp(k));
                max_overshoot = abs(y(k)-Ysp(k));
                overshoot(max_overshoot_idx) = 0;
                max_overshoot_idx = k;
            end
        end
    else
        overshooting = false;
        max_overshoot = 0;
        max_overshoot_idx = k;
    end
end