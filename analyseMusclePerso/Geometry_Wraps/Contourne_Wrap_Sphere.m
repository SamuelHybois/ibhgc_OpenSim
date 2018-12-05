clear all
close all

% 1- Compute locations of obstacle via points
% O = Origine of the sphere, R= Radius
O = [0,0,0]';
R = 0.5;
% P Bounding-fixed via points Start of path
P = [1,1,1.2]';
% S Bounding-fixed via points END of path
S = [-1,-1.1,-1.4]';

[X1,Y1,Z1] = sphere(20);
surf(R*X1+O(1),R*Y1+O(2),R*Z1+O(3))
shading flat
hold on

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

%equation de cercle : x^2+y^2=R^2
%equatino de droite : y = a*x+b avec :
a = (s(2)-p(2))/(s(1)-p(1));
b = p(2)-a*p(1);
% on injecte dans l'équation de cercle y
%x^2 + (a*x+b)^2=R^2
%x^2 + a^2*x^2+ 2*a*b*x + b^2=R^2
%  (a^2+1)*x^2+ 2*a*b*x + b^2-R^2 =0
% On calcule le déterminant
DD = (2*a*b)^2-4*(a^2+1)*(b^2-R^2);

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

   n= round(abs(theta1-theta2)/3,0);
   
   theta = linspace(theta1,theta2,n);
   
   x = R*cosd(theta);
   y = R*sind(theta);
   M=zeros(3,n);
   for i=1:n
   M(1:3,i) = M_rot*[x(i);y(i);0];
   scatter3(M(1,i),M(2,i),M(3,i),'k*')
   end      
   
elseif det(A)<0
    line([P(1) S(1)],[P(2) S(2)],[P(3) S(3)])
elseif det(A)==0
    disp('les points sont colinéaires');
end
