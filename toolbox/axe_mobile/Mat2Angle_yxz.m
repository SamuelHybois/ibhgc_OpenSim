function Angles = Mat2Angle_yxz(Matrice,sign)
% Fonction pour extraire les angles d'une matrice de rotation
% IN
%   Matrice : matrice de rotation 3*3
%   sign : sens du repère 1:directe, -1:indirecte
% OUT
%    Angles : triplettes des angles de Cardan (axes mobiles) en DEGRES!

    Angles(1) = sign*atand(Matrice(1,3)/Matrice(3,3));   %Y
    Angles(2) = -pi/2*(sign-1)-sign*asind(Matrice(2,3)); %X
    Angles(3) = atand(Matrice(2,1)/Matrice(2,2));        %Z 
    
end %function