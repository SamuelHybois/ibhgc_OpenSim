function [N,P] = subdivise_movie(N,P,Info) ;
%
% Fonction de subdivision de maillage movie triangul� :
%

%
% 1. Gestion des donn�es d'entr�e
%
if nargin == 2 ;
    % ---> Il faut les informations sur le maillage
    [Info,P] = analyse_geometrie_polygones(P,N) ;
end
%
% 2. Cr�ation de la nouvelle liste de noeuds ;
%
NN = size(N,1) ; % Nombre de noeuds origine
N = [N;Info.Barycentre] ;
%
% 3. Cr�ation des nouveaux polygones
%
NP = size(P,1) ;        % Nombre de Polygones origine
Bary = (NN + [1:NP])' ; % Num�ros des points barycentres
P = [[P(:,[1,2]),Bary];[P(:,[2,3]),Bary];[P(:,[3,1]),Bary]] ;
%
% ---> Fin de la fonction