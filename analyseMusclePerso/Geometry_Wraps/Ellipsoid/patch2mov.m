function Movie = patch2mov(P) ;
%
% Nombre d'Objet : 1 toujours dans ce cas ...
%
Movie.N_Obj = 1 ;
%
% Nombre de points : Taille des Vertices :
%
Movie.N_Pts = size(P.vertices,1) ;
%
% Nombre de polygones : taille de faces :
%
Movie.N_Pol = size(P.faces,1) ;
%
% Nombre d'arrêtes : hypothèse pour le moment ---> nous avons à faire à des triangles seulement 
%
Movie.N_Arr = 3*Movie.N_Pol ;
%
% Définition des noeuds : se sont les vertices ...
%
Movie.Noeuds = P.vertices ;
%
% Définition des faces : faces + 0 
%
Movie.Polygones = P.faces ;
%
% Définition des limites des objets ...
%
Movie.Objets = [1 size(P.faces,1)] ;
%
% Fin de la fonction