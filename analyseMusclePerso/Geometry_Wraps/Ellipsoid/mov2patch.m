function P = mov2patch(Movie) ;
%
% Création des vertices :
%
P.vertices = Movie.Noeuds ;
%
% Créations des faces :
%
P.faces = Movie.Polygones(:,1:3) ;
%
% fin de la fonction