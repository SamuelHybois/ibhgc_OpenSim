%Reste à faire Améliorer le maillage => OK
%Approximation de la courbe 3D, pas réussi, on reste sur les splines.

%% Ellipsoid
clear all ;close all
n=30;
R1=3;
R2=4;
R3=5;
[x,y,z]=ellipsoid(0,0,0,R1,R2,R3,n);

%% 2 points
S=[4,2.1,2.6];
P=-S;
scatter3(P(1),P(2),P(3),'r*')
hold on
scatter3(S(1),S(2),S(3),'r*')
hold on
%Calcul des points les plus proches sur l'ellipsoid sur la droite
%equation d'ellipsoide x^2/a^2+y^2/b^2+z^2/c^2=1
%equation de droite parametrique 
%x = x0 +t*a_d
%y = y0 +t*b_d
%x = z0 +t*c_d
%N = S-P =PS 
%P + t_sol*N = [x;y;z]
N = S-P;
% % on injecte l'equation parametrique de droite dans l'equation de
% % l'ellipsoide, en développant, on obtient les coefficient d'un polynome
% % d'ordre 2 : Alpha * t_sol^2 + Beta * t_sol + Gamma = 0
Alpha =  N(1)^2/R1^2 + N(2)^2/R2^2 + N(3)^2/R3^2 ;
Beta = 2*(  P(1)*N(1)/R1^2 +  P(2)*N(2)/R2^2  + P(3)*N(3)/R3^2   );
Gamma = P(1)^2/R1^2 + P(2)^2/R2^2 + P(3)^2/R3^2 - 1 ;

p = [Alpha Beta Gamma];
t_sol = roots(p);
for j=1:3
    for i=1:2
        Pt_ellipsoid(i,j) = P(1,j) +N(1,j)*t_sol(i);
    end
end

scatter3(Pt_ellipsoid(1,1),Pt_ellipsoid(1,2),Pt_ellipsoid(1,3),'b*')
hold on
scatter3(Pt_ellipsoid(2,1),Pt_ellipsoid(2,2),Pt_ellipsoid(2,3),'b*')
hold on

%% reconcatenate points 
xy(:,1)=x(:);
xy(:,2)=y(:);
xy(:,3)=z(:);

xy=unique(xy,'rows'); % eliminate duplicate data points

tri = delaunay(xy(:,1),xy(:,2),xy(:,3));% actually it gives tetahedron
TR = triangulation(tri,xy);
[tri,xy] = freeBoundary(TR); %now we only have triangles
Ellipsoid.Polygones=tri;
Ellipsoid.Noeuds=xy;
Ellipsoid_opt=optimisation_objet_movie(Ellipsoid,500);
affiche_objet_movie(Ellipsoid_opt)

% ajout les 2 noeuds au maillage
for i_pt=1:2
xxx = Norm2( Ellipsoid_opt.Noeuds-Pt_ellipsoid(i_pt,:) );
[~,ind]=sort(xxx);

add_cdt = double(Ellipsoid_opt.Polygones==ind(1)); 
add_cdt = add_cdt + double(Ellipsoid_opt.Polygones==ind(2));
add_cdt = add_cdt + double(Ellipsoid_opt.Polygones==ind(3));
add_cdt = add_cdt(:,1)+add_cdt(:,2)+add_cdt(:,3);
[val,~] = find(add_cdt == 3);
% indice du polygone trouvé.
Noeuds = Ellipsoid_opt.Polygones(val,:);
Ellipsoid_opt.Polygones(val,:)=[];

Ellipsoid_opt.Noeuds(end+1,:)=Pt_ellipsoid(i_pt,:);
Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(1),Noeuds(2)];
Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(2),Noeuds(3)];
Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(3),Noeuds(1)];

affiche_objet_movie(Ellipsoid_opt)
hold on
scatter3(Pt_ellipsoid(i_pt,1),Pt_ellipsoid(i_pt,2),Pt_ellipsoid(i_pt,3),'b*')
hold on
end

trisurf(Ellipsoid_opt.Polygones,Ellipsoid_opt.Noeuds(:,1),Ellipsoid_opt.Noeuds(:,2),Ellipsoid_opt.Noeuds(:,3));hold on;axis equal;grid off;
%%
m = size(Ellipsoid_opt.Noeuds,1);
A = zeros(m);
I = Ellipsoid_opt.Polygones(:); J = Ellipsoid_opt.Polygones(:,[2 3 1]); J = J(:);

% no treshold needed now that we have cleaned the mesh. We just put 1 in
% the matrix A where data are connected by an edge. A(i,j) = 1 means the
% segment data i:data j is an edge of the mesh
IJ = I + m*(J-1); A(IJ) = 1;

%We look for the points on the line and the ellipsoid
clear ind
ind = find(Ellipsoid_opt.Noeuds(:,1)==Pt_ellipsoid(1,1));
if size(ind)>1
ind2 = find(Ellipsoid_opt.Noeuds(ind,2)==Pt_ellipsoid(1,2));
ind=ind(ind2);
end
indd = find(Ellipsoid_opt.Noeuds(:,1)==Pt_ellipsoid(2,1));
if size(indd)>1
ind2 = find(Ellipsoid_opt.Noeuds(indd,2)==Pt_ellipsoid(2,2));
indd=indd(ind2);
end

[cost,path] = dijkstra(A,Ellipsoid_opt.Noeuds,ind,indd);
xy_sol=Ellipsoid_opt.Noeuds(path,:);
%tetramesh(tri,xy,'FaceAlpha',0.2,'FaceColor','none'); hold on;
plot3(xy_sol(:,1),xy_sol(:,2),xy_sol(:,3),'ro-','LineWidth',2); hold on
title(sprintf('Distance = %1.3f',cost));axis equal

%% Approche Nouvelle
%ne fonctionne pas toujours le fitting de l'ellipse ne
%fonctionnne pas bien et on perd l'info de par où est contourné l'ellipse.

%On plus de fois le premier et le dernier point pour ajouter du poids au
%points.
nb_sol=size(xy_sol,1);
xy_sol2(nb_sol+1:nb_sol+5,:)=repmat(Pt_ellipsoid(1,:),[5,1]);
nb_sol=size(xy_sol2,1);
xy_sol2(nb_sol+1:nb_sol+5,:)=repmat(Pt_ellipsoid(2,:),[5,1]);

% On calcule le point
Plan=plan_moindres_carres(xy_sol2);
% on projette les points
xy_proj=Projection_points_plan(xy_sol2,Plan);

%Matrice de rotation entre le plan et le repère wraps
z_p=Plan(2,:)';
y_p=cross(Plan(2,:)',[0;1;0])/norm(cross(Plan(2,:)',[0;1;0]));
x_p=cross(z_p,y_p);

MH_R0_Rp=[x_p,y_p,z_p,Plan(1,:)';0,0,0,1];

xy_proj_Rp=zeros(size(xy_proj,1),4);
for j=1:size(xy_proj,1)
xy_proj_Rp(j,:)=(MH_R0_Rp\[xy_proj(j,:)';1])';
end

% Je vais perdre l'info par quelle coté l'ellipse est contournée
Ellipse=ellipse_moindres_carres_2D(xy_proj_Rp(1:end-10,1:2));
E=[];
for t=0:0.2:2*pi
x_e=Ellipse.a*cos(t)+Ellipse.Centroide(1);
y_e=Ellipse.b*sin(t)+Ellipse.Centroide(2);
E(end+1,1:2)=Ellipse.R*[x_e;y_e];
end

for j=1:size(E,1)
E_R0(j,:)=(MH_R0_Rp*[E(j,:)';0;1])';
end
plot3(E_R0(:,1),E_R0(:,2),E_R0(:,3),'bo-','LineWidth',2)

%% Approche Nouvelle 2
%Ne marche pas mieux
newCurve = spline3dCurveInterpolation(xy_sol,45-1);
% newCurve = spline3dCurveApproximation(xy(path,:),45-1);% ne fonctionna
% pas
hold on
plot3(newCurve(:,1),newCurve(:,2),newCurve(:,3),'bo-','LineWidth',2)

%On plus de fois le premier et le dernier point pour ajouter du poids au
%points.
nb_sol=size(newCurve,1);
newCurve(nb_sol+1:nb_sol+5,:)=repmat(Pt_ellipsoid(1,:),[5,1]);
nb_sol=size(newCurve,1);
newCurve(nb_sol+1:nb_sol+5,:)=repmat(Pt_ellipsoid(2,:),[5,1]);

% On calcule le point
Plan=plan_moindres_carres(newCurve);
% on projette les points
xy_proj=Projection_points_plan(newCurve,Plan);

%Matrice de rotation entre le plan et le repère wraps
z_p=Plan(2,:)';
y_p=cross(Plan(2,:)',[0;1;0])/norm(cross(Plan(2,:)',[0;1;0]));
x_p=cross(z_p,y_p);

MH_R0_Rp=[x_p,y_p,z_p,Plan(1,:)';0,0,0,1];

xy_proj_Rp=zeros(size(xy_proj,1),4);
for j=1:size(xy_proj,1)
xy_proj_Rp(j,:)=(MH_R0_Rp\[xy_proj(j,:)';1])';
end

% Je vais perdre l'info par quelle coté l'ellipse est contournée
Ellipse=ellipse_moindres_carres_2D(xy_proj_Rp(1:end-10,1:2));
E=[];
for t=0:0.2:2*pi
x_e=Ellipse.a*cos(t)+Ellipse.Centroide(1);
y_e=Ellipse.b*sin(t)+Ellipse.Centroide(2);
E(end+1,1:2)=Ellipse.R*[x_e;y_e];
end

for j=1:size(E,1)
E_R0(j,:)=(MH_R0_Rp*[E(j,:)';0;1])';
end
plot3(E_R0(:,1),E_R0(:,2),E_R0(:,3),'bo-','LineWidth',2)

%% Approche 1
newCurve = spline3dCurveInterpolation(xy_sol,45-1);
% newCurve = spline3dCurveApproximation(xy(path,:),45-1);% ne fonctionna
% pas
hold on
plot3(newCurve(:,1),newCurve(:,2),newCurve(:,3),'bo-','LineWidth',2)


%% Approche 2 % Approximation aux points données avec un polynomes à deux
%variable
% [theta,phi]=Ellipsoid_Cartesian2Parameters(xy_sol(:,:),R1,R2,R3);
% 
% P(1:length(path),1)=1;
% P(1:length(path),2)=theta;
% P(1:length(path),3)=phi;
% P(1:length(path),4)=phi.*theta;
% P(1:length(path),5)=theta.^2;
% P(1:length(path),6)=phi.^2;
% 
% ax = (P'*P)\P'*xy_sol(:,1);
% ay = (P'*P)\P'*xy_sol(:,2);
% az = (P'*P)\P'*xy_sol(:,3);
% 
% xp = P*ax;
% yp = P*ay;
% zp = P*az;
% 
% plot3(xp,yp,zp,'ko-','LineWidth',3)
% 
%% Approche 3 % Meme que précédement mais linéairement espacé entre le point 1
% et le point 2 : fonctionne pas.
% [theta,phi]=Ellipsoid_Cartesian2Parameters(xy_sol(:,:),R1,R2,R3);
% 
% P(1:length(path),1)=1;
% P(1:length(path),2)=theta;
% P(1:length(path),3)=phi;
% P(1:length(path),4)=phi.*theta;
% P(1:length(path),5)=theta.^2;
% P(1:length(path),6)=phi.^2;
% 
% ax = (P'*P)\P'*xy_sol(:,1);
% ay = (P'*P)\P'*xy_sol(:,2);
% az = (P'*P)\P'*xy_sol(:,3);
% 
% nn=45;
% dtheta = linspace(theta(1),theta(end),nn);
% dphi = linspace(phi(1),phi(end),nn);
% 
% P(1:nn,1)=1;
% P(1:nn,2)=dtheta;
% P(1:nn,3)=dphi;
% P(1:nn,4)=dphi.*dtheta;
% P(1:nn,5)=dtheta.^2;
% P(1:nn,6)=dphi.^2;
% 
% xp = P*ax;
% yp = P*ay;
% zp = P*az;
% 
% plot3(xp,yp,zp,'go-','LineWidth',3)
% 
%% Approche 4 même qu'avant mais polynome d'ordre 3 à deux variables.
% clear P
% [theta,phi]=Ellipsoid_Cartesian2Parameters(xy_sol(:,:),R1,R2,R3);
% 
% P(1:length(path),1)=1;
% P(1:length(path),2)=theta;
% P(1:length(path),3)=phi;
% P(1:length(path),4)=phi.*theta;
% P(1:length(path),5)=theta.^2;
% P(1:length(path),6)=phi.^2;
% P(1:length(path),7)=phi.*theta.^2;
% P(1:length(path),8)=phi.^2.*theta;
% P(1:length(path),9)=theta.^3;
% P(1:length(path),10)=phi.^3;
% 
% ax = (P'*P)\P'*xy_sol(:,1);
% ay = (P'*P)\P'*xy_sol(:,2);
% az = (P'*P)\P'*xy_sol(:,3);
% 
% nn=45;
% dtheta = linspace(theta(1),theta(end),nn);
% dphi = linspace(phi(1),phi(end),nn);
% 
% P_val(1:nn,1)=1;
% P_val(1:nn,2)=dtheta;
% P_val(1:nn,3)=dphi;
% P_val(1:nn,4)=dphi.*dtheta;
% P_val(1:nn,5)=dtheta.^2;
% P_val(1:nn,6)=dphi.^2;
% P_val(1:nn,7)=dphi.*dtheta.^2;
% P_val(1:nn,8)=dphi.^2.*dtheta;
% P_val(1:nn,9)=dtheta.^3;
% P_val(1:nn,10)=dphi.^3;
% 
% xp = P_val*ax;
% yp = P_val*ay;
% zp = P_val*az;
% 
% plot3(xp,yp,zp,'k*-','LineWidth',3)
% 
%% Approche 5 % Interpolation au points données et entre. (ordre 2)
% clear P
% clear P_val
% clear dtheta
% clear dphi
% [theta,phi]=Ellipsoid_Cartesian2Parameters(xy_sol(:,:),R1,R2,R3);
% 
% P(1:length(path),1)=1;
% P(1:length(path),2)=theta;
% P(1:length(path),3)=phi;
% P(1:length(path),4)=phi.*theta;
% P(1:length(path),5)=theta.^2;
% P(1:length(path),6)=phi.^2;
% 
% ax = (P'*P)\P'*xy_sol(:,1);
% ay = (P'*P)\P'*xy_sol(:,2);
% az = (P'*P)\P'*xy_sol(:,3);
% 
% nn=45;
% ll=length(theta);
% dtheta = [];
% dphi = [];
% for i_pt = 1:ll-1
% dtheta = [dtheta; linspace(theta(i_pt),theta(i_pt+1),round(nn/(ll-1),0))'];
% dphi = [dphi; linspace(phi(i_pt),phi(i_pt+1),round(nn/(ll-1),0))'];
% end
% 
% nnn = length(dtheta);
% P_val(1:nnn,1)=1;
% P_val(1:nnn,2)=dtheta;
% P_val(1:nnn,3)=dphi;
% P_val(1:nnn,4)=dphi.*dtheta;
% P_val(1:nnn,5)=dtheta.^2;
% P_val(1:nnn,6)=dphi.^2;
% 
% xp = P_val*ax;
% yp = P_val*ay;
% zp = P_val*az;
% 
% plot3(xp,yp,zp,'bs-','LineWidth',3)
% 
%% Approche 6 % même que précédement ordre 3
% clear P
% clear P_val
% clear dtheta
% clear dphi
% [theta,phi]=Ellipsoid_Cartesian2Parameters(xy_sol(:,:),R1,R2,R3);
% 
% P(1:length(path),1)=1;
% P(1:length(path),2)=theta;
% P(1:length(path),3)=phi;
% P(1:length(path),4)=phi.*theta;
% P(1:length(path),5)=theta.^2;
% P(1:length(path),6)=phi.^2;
% P(1:length(path),7)=phi.*theta.^2;
% P(1:length(path),8)=phi.^2.*theta;
% P(1:length(path),9)=theta.^3;
% P(1:length(path),10)=phi.^3;
% 
% ax = (P'*P)\P'*xy_sol(:,1);
% ay = (P'*P)\P'*xy_sol(:,2);
% az = (P'*P)\P'*xy_sol(:,3);
% 
% nn=45;
% ll=length(theta);
% dtheta = [];
% dphi = [];
% for i_pt = 1:ll-1
% dtheta = [dtheta; linspace(theta(i_pt),theta(i_pt+1),round(nn/(ll-1),0))'];
% dphi = [dphi; linspace(phi(i_pt),phi(i_pt+1),round(nn/(ll-1),0))'];
% end
% 
% nnn = length(dtheta);
% P_val(1:nnn,1)=1;
% P_val(1:nnn,2)=dtheta;
% P_val(1:nnn,3)=dphi;
% P_val(1:nnn,4)=dphi.*dtheta;
% P_val(1:nnn,5)=dtheta.^2;
% P_val(1:nnn,6)=dphi.^2;
% P_val(1:nnn,7)=dphi.*dtheta.^2;
% P_val(1:nnn,8)=dphi.^2.*dtheta;
% P_val(1:nnn,9)=dtheta.^3;
% P_val(1:nnn,10)=dphi.^3;
% 
% xp = P_val*ax;
% yp = P_val*ay;
% zp = P_val*az;
% 
% plot3(xp,yp,zp,'bs-','LineWidth',3)
% 
% % pas trouver de bonne méthode pour approximer...


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Recherche du point %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Tangent     %%%%%%%%%%%%%%%%%%%%%%%%%%%
% On prend la courbe spline de l'approche 1
[theta_s,phi_s]=Ellipsoid_Cartesian2Parameters(newCurve,R1,R2,R3);

%On vérifie pour tout les points lequel respect le mieux la contraintes de
%tangence entre le point à l'extérieur de l'ellispoide et les points de
%contour 

Res=zeros(length(theta_s),1);
for i=1:length(theta_s)
Res(i) = S(1)*cos(theta_s(i))*cos(phi_s(i))/R1 +...
    S(2)*cos(theta_s(i))*sin(phi_s(i))/R2 +...
    S(3)*sin(theta_s(i))/R3-1;
end
[val,ind1]=min(abs(Res));

pt_tangent(1,:)=newCurve(ind1,:);

%de meme pour le second points
Res=zeros(length(theta_s),1);
for i=1:length(theta_s)
Res(i) = P(1)*cos(theta_s(i))*cos(phi_s(i))/R1 +...
    P(2)*cos(theta_s(i))*sin(phi_s(i))/R2 +...
    P(3)*sin(theta_s(i))/R3-1;
end
[val,ind2]=min(abs(Res));

pt_tangent(2,:)=newCurve(ind2,:);

line( [P(1) pt_tangent(2,1)],...
[P(2) pt_tangent(2,2)],...
[P(3) pt_tangent(2,3)]);

line( [S(1) pt_tangent(1,1)],...
[S(2) pt_tangent(1,2)],...
[S(3) pt_tangent(1,3)]);

PathContourne = newCurve(ind1:ind2,:);
plot3(PathContourne(:,1),PathContourne(:,2),PathContourne(:,3),'r--','LineWidth',2)
