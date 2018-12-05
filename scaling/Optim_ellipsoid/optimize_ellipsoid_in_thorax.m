function var_ellipsoid_optim = optimize_ellipsoid_in_thorax(scap_center_in_thorax,var_ellipsoid_init)
% Initialize the optimization for ellipsoid functional calibration

x_min = min(scap_center_in_thorax(:,1));

lb = [-pi/2 -pi -pi/2 x_min -0.3 -0.3 0.01 0.01  0.01];
ub = [ pi/2  pi  pi/2  0.3  0.3  0.3 0.3  0.3   0.3 ];
A=[];
b=[];
Aeq=[];
beq=[];

fun_obj = @(var_ellipsoid)squared_scaploc2ellispoid_distance(var_ellipsoid,scap_center_in_thorax);
options = optimset('Display','iter','TolX',1e-4);

[var_ellipsoid_optim,distance_opt,~,~] = fmincon(fun_obj,var_ellipsoid_init,A,b,Aeq,beq,lb,ub,[],options) ;

end %function