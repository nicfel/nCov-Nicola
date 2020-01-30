growth = 20; % growth rate per day
a = 1;
b = 1/10*365;
y = gamrnd(a,b,10000,1);

fprintf('%f %f\n', quantile(y, 0.025)*365,quantile(y,0.975)*365);

disp((1+growth/b))