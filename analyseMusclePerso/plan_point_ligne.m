P1_m = [-0.7194 0.9594 0.9579];
P2_m = [-0.7579 0.8568 0.9867];
P_Cor = [ -0.7618 0.8687 0.9299];

scatter3(P1_m(1),P1_m(2),P1_m(3),'ro')
hold on
scatter3(P2_m(1),P2_m(2),P2_m(3),'ro')
hold on
ezplot3(line(1), line(2), line(3), [-1,3]), hold on

scatter3(P_Cor(1),P_Cor(2),P_Cor(3),'go')
hold on

% droite parametrique 3D
syms t
N = (P2_m-P1_m);
line = P1_m + t*N;

% Equation de plan 3D
syms x y z
plan = N(1)*x+N(2)*y+N(3)*z - (N(1)*P_Cor(1)+N(2)*P_Cor(2)+N(3)*P_Cor(3));

% Resolution Intersection Plan - Droite

eq_pt = N(1)*line(1) +N(2)*line(2) +N(3)* line(3) - (N(1)*P_Cor(1)+N(2)*P_Cor(2)+N(3)*P_Cor(3));

t_pt = solve(eq_pt,t);

% On réinjecte le paramètre dans l'equation de droite

pt = double(P1_m + t_pt*N);

scatter3(pt(1),pt(2),pt(3),'b*')
hold on