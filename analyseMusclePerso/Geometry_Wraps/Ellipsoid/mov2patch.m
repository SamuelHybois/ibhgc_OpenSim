function P = mov2patch(Movie) ;
%
% Cr�ation des vertices :
%
P.vertices = Movie.Noeuds ;
%
% Cr�ations des faces :
%
P.faces = Movie.Polygones(:,1:3) ;
%
% fin de la fonction