function d = distancePointEllipsoide(P,R,O)
%%
% P [Px, Py, Pz] : coordonnées du point dont on cherche la distance à
% l'ellipsoide
% R [Rx, Ry, Rz] : rayons de l'ellipsoide suivant les 3 directions
% O [Ox, Oy, Oz] : coordonnées du centre de l'ellipsoide par rapport à
% l'origine du repère global

%% Paramètres de l'ellipsoide et du point
Px = P(1) ;
Py = P(2) ;
Pz = P(3) ;
Rx = R(1) ;
Ry = R(2) ;
Rz = R(3) ;
Ox = O(1) ;
Oy = O(2) ;
Oz = O(3) ;

%% Coefficients du polynôme issu du multiplicateur de Lagrange
a6 = -1 ;

a5 = -2*(Rx^2+Ry^2+Rz^2) ;

a4 = ((Ox-Px)^2*Rx^2-Rx^4+(Oy-Py)^2*Ry^2-4*Rx^2*Ry^2-Ry^4+(Oz-Pz)^2*Rz^2-...
    4*Rx^2*Rz^2-4*Ry^2*Rz^2-Rz^4) ;

a3 = 2*((Ox-Px)^2*Rx^2*Ry^2+(Oy-Py)^2*Rx^2*Ry^2-Rx^4*Ry^2-Rx^2*Ry^4+...
    (Ox-Px)^2*Rx^2*Rz^2+(Oz-Pz)^2*Rx^2*Rz^2-Rx^4*Rz^2+(Oy-Py)^2*Ry^2*Rz^2+...
    (Oz-Pz)^2*Ry^2*Rz^2-4*Rx^2*Ry^2*Rz^2-Ry^4*Rz^2-Rx^2*Rz^4-Ry^2*Rz^4) ;

a2 = ((Oy-Py)^2*Rx^4*Ry^2+(Ox-Px)^2*Rx^2*Ry^4-Rx^4*Ry^4+(Oz-Pz)^2*Rx^4*Rz^2+...
    4*(Ox-Px)^2*Rx^2*Ry^2*Rz^2+4*(Oy-Py)^2*Rx^2*Ry^2*Rz^2+4*(Oz-Pz)^2*Rx^2*Ry^2*Rz^2-...
    4*Rx^4*Ry^2*Rz^2+(Oz-Pz)^2*Ry^4*Rz^2-4*Rx^2*Ry^4*Rz^2+(Ox-Px)^2*Rx^2*Rz^4-...
    Rx^4*Rz^4+(Oy-Py)^2*Ry^2*Rz^4-4*Rx^2*Ry^2*Rz^4-Ry^4*Rz^4) ;

a1 = 2*Rx^2*Ry^2*Rz^2*((Oy-Py)^2*Rx^2+(Oz-Pz)^2*Rx^2+(Ox-Px)^2*Ry^2+(Oz-Pz)^2*Ry^2-...
    Rx^2*Ry^2+(Ox-Px)^2*Rz^2+(Oy-Py)^2*Rz^2-Rx^2*Rz^2-Ry^2*Rz^2) ;

a0 = (Oz-Pz)^2*Rx^4*Ry^4*Rz^2+(Oy-Py)^2*Rx^4*Ry^2*Rz^4+(Ox-Px)^2*Rx^2*Ry^4*Rz^4 - Rx^4*Ry^4*Rz^4 ;

Poly = [a6 a5 a4 a3 a2 a1 a0] ;

%% Recherche des racines : valeurs du multiplicateur de Lagrange permettant d'atteindre les extremum.

r0 = roots(Poly) ;
r0 = r0(imag(r0)==0);

%% On reporte les valeurs de lambda dans Qx*, Qy*, Qz* 
Qx = (Px*Rx^2+r0.*Ox)./(Rx^2+r0) ;
Qy = (Py*Ry^2+r0.*Oy)./(Ry^2+r0) ;
Qz = (Pz*Rz^2+r0.*Oz)./(Rz^2+r0) ;

Jq = sqrt((Px-Qx).^2+(Py-Qy).^2+(Pz-Qz).^2) ;
d = min(Jq) ;
end