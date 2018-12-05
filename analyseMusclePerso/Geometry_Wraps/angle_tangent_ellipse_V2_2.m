function t_Q = angle_tangent_ellipse_V2_2(a,b,P_x,P_y)


%from mathematica
n=1;

    t_Q = 2*(n*pi + atan((sqrt(a^2 *(P_y^2-b^2 )+b^2*P_x^2 )+ a*P_y)/(b *(a + P_x ) )));
    


end