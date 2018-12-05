function t_Q = angle_tangent_ellipse_V2(a,b,P_x,P_y)


%from mathematica
%works for p_x>0 et p_y>0;
n=1;
try
    
   t_Q = 2*(n*pi + atan ( (a*P_y  - sqrt(b^2*P_x^2+ a^2 *( P_y^2-b^2 ) ) ) /(b*(a + P_x) ))) ;
catch
   t_Q = 2*(n*pi + atan((sqrt(a^2 *(P_y^2-b^2 )+b^2*P_x^2 )+ a*P_y)/(b *(a + P_x ) )));
    
end
end