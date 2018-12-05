function t_Q = angle_tangent_ellipse_2(a,b,P_x,P_y)
%
%Don't work
Y = a*b^2*P_x - sqrt( -a^4*b^2*P_y^2 + a^4*P_y^4 + a^2*b^2*P_x^2*P_y^2 )/...
( a^2*P_y^2 + b^2*P_x^2 );

X = (( b*P_x * sqrt(-a^2*P_y^2*( a^2*b^2 -a^2*P_y^2 - b^2*P_x^2 ) )...
/( a^2*P_y^2 + b^2*P_x^2 ) - (a*b^3*P_x^2)/...
(a^2*P_y^2+b^2*P_x^2 )+a*b)/(a*P_y )) ;

t_Q = atan2(Y,X);

end
