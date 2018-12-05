function Angles = Mat2Angle_xyz(Matrice,sign)
% Fonction pour extraire les angles d'une matrice de rotation
% IN
%   Matrice : matrice de rotation 3*3
%   sign : sens du repère 1:directe, -1:indirecte
% OUT
%    Angles : triplettes des angles de Cardan (axes mobiles) en DEGRES!

    Angles(1) = -pi/2*(sign-1)-sign*atand(Matrice(2,3)/Matrice(3,3)); %X
    Angles(2) = sign*asind(Matrice(3,1));                             %Y
    Angles(3) = atand(Matrice(2,1)/Matrice(1,1));                     %Z 
    
end %function