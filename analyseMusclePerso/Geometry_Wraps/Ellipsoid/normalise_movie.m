% [N,P] = normalise_movie(N,P) ;
%
% ---> Fonction de normalisation d'un objet movie :
%
function [N,P] = normalise_movie(N,P) ;
%
% 1. Variables d'entrée
%
if nargin == 1 ;
    % --> Mise en forme N P
    P = N.Polygones ;
    N = N.Noeuds ;
end
%
% 2. Triangularisation et retrait des triangles de surface nulle
%
[N,P] = nettoie_maillage_NP(N,P) ;
%
% 3. Supression des arretes mal définies
%
[N,P] = nettoie_movie_arr(N,P) ;
%
% 4. Variable de sortie
%
if nargout == 1 ;
    % ---> Mise en forme movie
    P2.vertices = N ;
    P2.faces = P ;
    N = patch2mov(P2) ;
end
%
% Fin de la fonction