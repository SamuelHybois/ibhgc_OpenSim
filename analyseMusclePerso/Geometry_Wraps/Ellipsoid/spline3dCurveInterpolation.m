function [newCurve,sx,sy,sz] = spline3dCurveInterpolation(curve, nb_pt)
% interpote a 3d curve using spline
% path 3*x
% newPath 3*x
curve_reshaped=curve';
x = curve_reshaped(1, :);
y = curve_reshaped(2, :);
z = curve_reshaped(3, :);

t = cumsum([0;sqrt(diff(x(:)).^2 + diff(y(:)).^2 + diff(z(:)).^2)]);
sx = spline(t,x);
sy = spline(t,y);
sz = spline(t,z);

dt=t(end)/nb_pt;

tt = t(1):dt:t(end);
xp = ppval(sx, tt);
yp = ppval(sy, tt);
zp = ppval(sz, tt);

newCurve = [xp; yp; zp]';
end