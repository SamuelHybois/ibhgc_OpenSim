%loc_ellipsoid
%dim_ellipsoid
varIni = [-0.026 , -0.0225, 0.0909, 0.0909, 0.1948, 0.0909] ;
lb = [-0.1       ,   -0.1    ,   -0.1    ,  0.01       ,  0.01 ,  0.01  ] ;
ub = [ 0.1       ,    0.1     ,  0.1     ,  0.3       ,   0.3  ,   0.3  ] ;
tic
fun_obj =  @(varEllipsoide)calculDistanceScapulaEllipsoide(path_c3d,t_debut,t_fin,varEllipsoide);

A=[];
b=[];
Aeq=[];
beq=[];
options = optimset('Display','iter','TolX',1e-4);
[x_opt,f_opt,~,~] = fmincon(fun_obj,varIni,A,b,Aeq,beq,lb,ub,[],options) ;

tCalc = toc