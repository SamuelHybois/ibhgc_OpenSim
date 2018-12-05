clear all
close all

% 1- Compute locations of obstacle via points
% O = Origine of the sphere, R= Radius
O = [0,0,0]';
R1 = 0.8;
R2 = 0.7;
R3 = 0.2;

maxd = 1.25 * max( [ R1 R2 R3 ] );
step = maxd / 50;
[ x, y, z ] = meshgrid( -maxd:step:maxd +0, -maxd:step:maxd +0, -maxd:step:maxd +0 );
%Equation de l'ellipsoid
v=[1/R1^2 1/R2^2 1/R3^2 0 0 0 0 0 0 -1];
%conique ellipsoid
Ellipsoid = v(1) *x.*x + v(2) * y.*y + v(3) * z.*z + ...
          2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
          2*v(7) *x + 2*v(8)*y + 2*v(9) * z ;

pp = patch( isosurface( x, y, z, Ellipsoid,1) );
set( pp, 'FaceColor', 'g', 'EdgeColor', 'y','FaceAlpha',.2,'EdgeAlpha',.2 );
view( -70, 40 );
axis vis3d;
lighting phong;
hold on
axis equal
grid off

% P Bounding-fixed via points Start of path
P = [1.1,1.12,1.1]';
% S Bounding-fixed via points END of path
S = [-1.1,-1.2,-0.75]';
scatter3(P(1),P(2),P(3),'r*')
scatter3(S(1),S(2),S(3),'r*')
scatter3(O(1),O(2),O(3),'b*')
line( [S(1) P(1)],[S(2) P(2)],[S(3) P(3)])

% OS = (S-O)/norm(S-O) ;
% OP = (P-O)/norm(P-O) ;

%Calcul du points le plus proche de O le centre de l'ellipsoid sur la droite PS
N = S-P;
t_pt = ( (N(1)*O(1)+N(2)*O(2)+N(3)*O(3)) - (N(1)*P(1)+N(2)*P(2)+N(3)*P(3)) )...
     / ( N(1)^2 +N(2)^2 +N(3)^2);
O_prime = double(P + t_pt*N);
scatter3(O_prime(1),O_prime(2),O_prime(3),'b*')

% Definition du repère
O_primeP = (P-O_prime)/norm(P-O_prime);
Nz = O-O_prime/norm(O-O_prime); % Normal direction O'O vers le centre de l'ellipsoid
NN = cross(Nz,O_primeP);

quiver3(O(1),O(2),O(3),O_primeP(1),O_primeP(2),O_primeP(3))
quiver3(O(1),O(2),O(3),Nz(1),Nz(2),Nz(3))
quiver3(O(1),O(2),O(3),NN(1),NN(2),NN(3))

%Calcul des points les plus proches sur l'ellipsoid sur la droite
%equation d'ellipsoide x^2/a^2+y^2/b^2+z^2/c^2=1
%equation de droite parametrique 
%x = x0 +t*a_d
%y = y0 +t*b_d
%x = z0 +t*c_d
%N = S-P =PS 
%P + t_sol*N = [x;y;z]
N = S-P;
% on injecte l'equation parametrique de droite dans l'equation de
% l'ellipsoide, en développant, on obtient les coefficient d'un polynome
% d'ordre 2 : Alpha * t_sol^2 + Beta * t_sol + Gamma = 0
Alpha =  N(1)^2/R1^2 + N(2)^2/R2^2 + N(3)^2/R3^2 ;
Beta = 2*(  P(1)*N(1)/R1^2 +  P(2)*N(2)/R2^2  + P(3)*N(3)/R3^2   );
Gamma = P(1)^2/R1^2 + P(2)^2/R2^2 + P(3)^2/R3^2 - 1 ;

p = [Alpha Beta Gamma];
t_sol = roots(p);
for j=1:3
    for i=1:2
        Pt_ellipsoid(j,i) = P(j,1) +N(j,1)*t_sol(i);
    end
end

scatter3(Pt_ellipsoid(1,1),Pt_ellipsoid(2,1),Pt_ellipsoid(3,1),'b*')
scatter3(Pt_ellipsoid(1,2),Pt_ellipsoid(2,2),Pt_ellipsoid(3,2),'b*')
M = (Pt_ellipsoid(:,1)+Pt_ellipsoid(:,2))/2;
scatter3(M(1,1),M(2,1),M(3,1),'bo')

% % Definition du repère
% MP = (P-M)/norm(P-M);
% Nz = O-M/norm(O-M); % Normal direction O'O vers le centre de l'ellipsoid
% NN = cross(Nz,MP);
% %Nz = cross(NN,MP);
% 
% quiver3(O(1),O(2),O(3),MP(1),MP(2),MP(3))
% quiver3(O(1),O(2),O(3),Nz(1),Nz(2),Nz(3))
% quiver3(O(1),O(2),O(3),NN(1),NN(2),NN(3))

%Rotation Matrix R_R_0_plan
% P_R_0 = M_R_0_R_plan * P_R_plan
x1 = O_primeP;
y1 = NN; 
z1 = Nz;

M_rot = [ x1, y1, z1];

%Express P and S in the plane reference frame;
p = M_rot'*P;
s = M_rot'*S;
%s(3) = p(3) = cste

%On cherche les plans qui découpe l'ellipsoid de normal Z passant par S et
%P pour déterminer

%Equation de plan de normal z1 passant par M
% Ax *x + Ay*y + Az *z +Ad =0
Ax =z1(1);
Ay =z1(2);
Az =z1(3);
Ad = - Ax*M(1)- Ay*M(2)- Az*M(3);

axis equal
maxd = 1.5*max( [ R1 R2 R3 ] );
[x,y]=meshgrid(-maxd:1:maxd);
zv=@(x,y)(Ax*x+Ay*y+Ad)/-Az;
r=zv(x,y);
surf(x,y,r)
hold on
xlabel('x'); ylabel('y'); zlabel('z')

[a_0,b_0,q1,q2,q3,angle]=EllipsoidPlaneIntersection(Ax,Ay,Az,Ad,R1,R2,R3);

scatter3(q1,q2,q3,'g*')
Q=[q1;q2;q3];
q=M_rot'*Q;

% %Ellipse Conique 3D
% A= 1/R1^2 + Ax^2 / (Az^2 * R3^2);
% B= (2*Ax*Ay ) / (Az^2 * R3^2);
% C= 1/R2^2 + Ay^2 / (Az^2 * R3^2) ;
% D= 2*Ax*Ad / (Az^2 * R3^2);
% E= 2*Ay*Ad / (Az^2 * R3^2);
% F= Ad^2  / (Az^2* R3^2) - 1;
% 
% 
% Mo = [F     D/2     E/2;...
%       D/2   A       B/2;...
%       E/2   B/2     C  ];
%   
% M  = [A     B/2;...
%       B/2   C];
%   
% %V eigenvalues of M matrices (V(1)< V(2))
% V = eig(M);
% 
% a_0 = sqrt(-det(Mo) /( det(M)*V(1) )); %(major semi-axis of intersection ellipse) (6)
% b_0 = sqrt(-det(Mo) /( det(M)*V(2) ));%(minor semi-axis of intersection ellipse) (7)
% 
% Xo=(B*E-2 *C *D) / (4 *A *C-B^2); %(8)
% Yo=(B *D-2*A* E) / (4 *A *C-B^2); %(coordinates of intersection ellipse’s center) (9)
% Zo= -(Ax *Xo + Ay *Yo + Ad ) / Az; %(10)
% 
% %(orientation angle of projection ellipse) (11)
% theta = atan(B/(A-C))/2;%-pi;
% t= theta;
t = angle+pi/2;

%rotation R_plan_R_ellipse
M_rot_Rplan_Rellipse = [cos(t) -sin(t) 0;...
                 sin(t) cos(t) 0;...
                 0      0      1];
             
%On passe les points dans le repère de l'ellipse
p_e=M_rot_Rplan_Rellipse'*p;
s_e=M_rot_Rplan_Rellipse'*s;


% figure
% plot(p(1),p(2),'r*')
% hold on
% axis equal
% plot(p_e(1),p_e(2),'k*')
% plot(s(1),s(2),'r*')
% plot(s_e(1),s_e(2),'k*')

%Ellispe
% vertical radius
x0=0; % x0,y0 ellipse centre coordinates
y0=0;
x=[];y=[];z=[];
for tt=-pi:0.01:pi
x(end+1)=x0+a_0*cos(tt);
y(end+1)=y0+b_0*sin(tt);
z(end+1)=q(3);
end
% plot(x,y)
% plot(x0,y0,'r+')
% line([p_e(1) s_e(1)],[p_e(2) s_e(2)])

t_Q = angle_tangent_ellipse_final(a_0,b_0,p_e(1),p_e(2));

for i=1:2 
q_ex=x0+a_0*cos(t_Q(i));
q_ey=y0+b_0*sin(t_Q(i));
q_ez=q(3);
% plot(q_ex,q_ey,'r*');
% line([p_e(1) q_ex],[p_e(2) q_ey])
end

t_T = angle_tangent_ellipse_final(a_0,b_0,s_e(1),s_e(2));

for i=1:2 
t_ex=x0+a_0*cos(t_T(i));
t_ey=y0+b_0*sin(t_T(i));
t_ez=q(3);
% plot(t_ex,t_ey,'o');
% line([s_e(1) t_ex],[s_e(2) t_ey])
end

% Etapes suivante replacer les points tangents à l'ellipse dans le repère globale

QQ = M_rot*(M_rot_Rplan_Rellipse*[q_ex;q_ey;q_ez]+q);
T = M_rot*M_rot_Rplan_Rellipse*[t_ex;t_ey;t_ez];
OOO = M_rot*M_rot_Rplan_Rellipse'*[0;0;0]; % ok pour le zero
X = M_rot*(M_rot_Rplan_Rellipse*[x;y;z]);

h1 =scatter3(QQ(1),QQ(2),QQ(3),'ro','filled');
 set(h1, 'SizeData', 200);
h2 =scatter3(T(1),T(2),T(3),'ro','filled');
 set(h2, 'SizeData', 200);
h2 =scatter3(OOO(1),OOO(2),OOO(3),'ro','filled');
 plot3(X(1,:),X(2,:),X(3,:),'LineWidth',4)
 
 
% Calculer les points sur l'ellipsoide pour lier les deux lignes tangentes
% %Wrapping condition
% Ax=[q(1:2)',t(1:2)'];
% det(Ax)
% 
% if det(Ax)>0   %wraps occur
%     line([P(1) Q(1)],[P(2) Q(2)],[P(3) Q(3)])
%     line([S(1) T(1)],[S(2) T(2)],[S(3) T(3)])
%     
%    QT_tot = norm(q-t);
%    
%    theta1 = 2*atand(q(2)/ (q(1) + sqrt( q(1)^2 + q(2)^2 ) ));
%    theta2 = 2*atand(t(2)/ (t(1) + sqrt( t(1)^2 + t(2)^2 ) ));
% 
%    n= round(abs(theta1-theta2)/3,0);
%    
%    theta = linspace(theta1,theta2,n);
%    z_t = linspace(q(3),t(3),n);
%    
%    %need equation parametrique de la surface
%    
%    x = R*cosd(theta);
%    y = R*sind(theta);
%    z = z_t;
%    
%    M=zeros(3,n);
%    for i=1:n
%    M(1:3,i) = M_rot*[x(i);y(i);z(i)];
%    scatter3(M(1,i),M(2,i),M(3,i),'k*')
%    end      
%    
% elseif det(Ax)<0
%     line([P(1) S(1)],[P(2) S(2)],[P(3) S(3)])
% elseif det(Ax)==0
%     disp('les points sont colinéaires');
% end
