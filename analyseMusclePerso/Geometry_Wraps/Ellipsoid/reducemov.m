% Mov2 = reducemov(Mov1,varargin)
%
% Fonction de réduction du nombre de facette dans un objet movie
% ---> Voir reducepatch ...
%
function Mov2 = reducemov(Mov1,varargin)
%
% 1. Transformation de l'objet movie en objet patch :
%
P1 = mov2patch(Mov1) ;
%
% 2. Réduction du nombre de facettes
%
P2 = reducepatch(P1,varargin{:}) ;
%
% 3. Paasage en form de movie
%
Mov2 = patch2mov(P2) ;
%
% Fin de la fonction