% 1- Compute locations of obstacle via points
% O = Origine of the sphere, R= Radius
O = [0,0,0]';
R=1;
R1 = 2;
R2 = 10;
R3 = 1;
M_S = [1/R1, 0, 0;...
      0   ,1/R2,0;...
      0   ,  0  ,1/R3];
% P Bounding-fixed via points Start of path
P_E = [1,1,1]';
% S Bounding-fixed via points END of path
S_E = [-1,-1.1,-1]';
% On scale à l'échelle de la sphere
P = M_S*[1,1,1]';
% S Bounding-fixed via points END of path
S = M_S*[-1,-1.1,-1]';

OS = (S-O)/norm(S-O) ;
OP = (P-O)/norm(P-O) ;

% unit vector normal to the plane (Z-axis)
N = cross(OP,OS)/norm(cross(OP,OS));
NN = cross(N,OS);

scatter3(P(1),P(2),P(3),'r*')
hold on
axis equal
grid off
scatter3(S(1),S(2),S(3),'r*')
scatter3(O(1),O(2),O(3),'b*')

quiver3(O(1),O(2),O(3),OS(1),OS(2),OS(3))
%quiver3(O(1),O(2),O(3),OP(1),OP(2),OP(3))
quiver3(O(1),O(2),O(3),N(1),N(2),N(3))
quiver3(O(1),O(2),O(3),NN(1),NN(2),NN(3))

%Rotation Matrix R_sphere_R_0
% P_R_0 = M_R_0_R_sphere * P_R_sphere
x1 = OS;
y1 = NN; 
z1 = N; % Normal au plan

M_rot = [ x1, y1, z1];

%Express P and S in the plane reference frame;
p = M_rot'*P;
s = M_rot'*S;

% circle tangency equation

q(1)= ( p(1)*R^2 - R*p(2)*sqrt(p(1)^2 + p(2)^2 - R^2) )/( p(1)^2 + p(2)^2 );
q(2)= ( p(2)*R^2 + R*p(1)*sqrt(p(1)^2 + p(2)^2 - R^2) )/( p(1)^2 + p(2)^2 );
q(3)=0;

t(1)= ( s(1)*R^2 + R*s(2)*sqrt(s(1)^2 + s(2)^2 - R^2) )/( s(1)^2 + s(2)^2 );
t(2)= ( s(2)*R^2 - R*s(1)*sqrt(s(1)^2 + s(2)^2 - R^2) )/( s(1)^2 + s(2)^2 );
t(3)=0;

Q = M_rot*q';
T = M_rot*t';

scatter3(Q(1),Q(2),Q(3),'go')
scatter3(T(1),T(2),T(3),'go')

[X1,Y1,Z1] = sphere(20);
surf(R*X1+O(1),R*Y1+O(2),R*Z1+O(3))
shading flat

%Wrapping condition
n = [1;1;1];
A=[q(1:2)',t(1:2)'];
det(A)

if det(A)>0   %wraps occurs
    line([P(1) Q(1)],[P(2) Q(2)],[P(3) Q(3)])
    line([S(1) T(1)],[S(2) T(2)],[S(3) T(3)])
    
   QT = R*acos(1.0- ( (q(1)-t(1) )^2 +(q(2)-t(2) )^2 )/ (2*R^2) );
   
   theta1 = 2*atand(q(2)/ (q(1) + sqrt( q(1)^2 + q(2)^2 ) ));
   theta2 = 2*atand(t(2)/ (t(1) + sqrt( t(1)^2 + t(2)^2 ) ));

   n= round(abs(theta1-theta2)/1.5,0);
   
   theta = linspace(theta1,theta2,n);
   
   x = R*cosd(theta);
   y = R*sind(theta);
   M=zeros(3,n);
   for i=1:n
   M(1:3,i) = M_rot*[x(i);y(i);0];
   scatter3(M(1,i),M(2,i),M(3,i),'k*')
   end      
   
   figure
   M_E=zeros(3,n);
   
   scatter3(P_E(1),P_E(2),P_E(3),'r*')
   hold on
   axis equal
   grid off
   scatter3(S_E(1),S_E(2),S_E(3),'r*')
   scatter3(O(1),O(2),O(3),'b*')
   
   Q_E=inv(M_S)*Q;
   T_E=inv(M_S)*T;
   scatter3(Q_E(1),Q_E(2),Q_E(3),'go')
   scatter3(T_E(1),T_E(2),T_E(3),'go')
   line([P_E(1) Q_E(1)],[P_E(2) Q_E(2)],[P_E(3) Q_E(3)])
   line([S_E(1) T_E(1)],[S_E(2) T_E(2)],[S_E(3) T_E(3)])
   
   for i=1:n
       M_E(1:3,i) =inv(M_S)*M(1:3,i);
       scatter3(M_E(1,i),M_E(2,i),M_E(3,i),'k*')
       hold on
   end
   
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
   
   
elseif det(A)<0
    line([P(1) S(1)],[P(2) S(2)],[P(3) S(3)])
elseif det(A)==0
    disp('les points sont colinéaires');
end
