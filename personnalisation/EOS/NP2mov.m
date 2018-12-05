function Movie = NP2mov(N,P) ;
%
% Nombre d'Objet : 1 toujours dans ce cas ...
%
Movie.N_Obj = 1 ;
%
% Nombre de points : Taille des Vertices :
%
Movie.N_Pts = size(N,1) ;
%
% Nombre de polygones : taille de faces :
%
Movie.N_Pol = size(P,1) ;
%
% Nombre d'arr�tes : hypoth�se pour le moment ---> nous avons � faire � des triangles seulement 
%
Movie.N_Arr = 3*Movie.N_Pol ;
%
% D�finition des noeuds : se sont les vertices ...
%
Movie.Noeuds = N ;
%
% D�finition des faces : faces + 0 
%
Movie.Polygones = P ;
%
% D�finition des limites des objets ...
%
Movie.Objets = [1 size(P,1)] ;
%
% Fin de la fonction