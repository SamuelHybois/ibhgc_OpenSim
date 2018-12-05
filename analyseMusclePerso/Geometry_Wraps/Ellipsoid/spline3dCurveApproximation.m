function newCurve = spline3dCurveApproximation(curve, dt)
% interpote a 3d curve using spline
% path 3*x
% newPath 3*x
curve=curve';
x = curve(1, :);
y = curve(2, :);
z = curve(3, :);

t = cumsum([0;sqrt(diff(x(:)).^2 + diff(y(:)).^2 + diff(z(:)).^2)]);

P = [t.^0 t.^1 t.^2 t.^3 t.^4 t.^5];
Yx = x';
Yy = y';
Yz = z';

ax = (P'*P)\P'*Yx;
ay = (P'*P)\P'*Yy;
az = (P'*P)\P'*Yz;

dt=t(end)/dt;

tt = t(1):dt:t(end);
xp = polyval(ax, tt);
yp = polyval(ay, tt);
zp = polyval(az, tt);

newCurve = [xp; yp; zp]';
end