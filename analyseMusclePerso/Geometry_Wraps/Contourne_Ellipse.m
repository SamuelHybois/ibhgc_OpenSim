clear all
close all

%Ellispe

P_x = 1;
P_y = 2;

plot(P_x,P_y,'r*')
hold on

a = 0.5;
b = 0.7;

% vertical radius
x0=0; % x0,y0 ellipse centre coordinates
y0=0;
t=-pi:0.01:pi;
x=x0+a*cos(t);
y=y0+b*sin(t);
plot(x,y)

t_Q = angle_tangent_ellipse_V2(a,b,P_x,P_y);

%t_Q = angle_tangent_ellipse(a,b,P_x,P_y);


Q_x=x0+a*cos(t_Q);
Q_y=y0+b*sin(t_Q);
plot(Q_x,Q_y,'g*');

line([P_x Q_x],[P_y Q_y])

S_x = -1.1;
S_y = -1.5;

plot(S_x,S_y,'r*')
hold on

t_T = angle_tangent_ellipse_V2(a,b,S_x,S_y);

T_x=x0+a*cos(t_T);
T_y=y0+b*sin(t_T);
plot(T_x,T_y,'g*');

line([S_x T_x],[S_y T_y])
