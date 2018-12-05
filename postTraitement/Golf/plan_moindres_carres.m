function [N,P] = plan_moindres_carres(M)
%
% [Normale,Point] = plan_moindres_carres(M)
% Plan = plan_moindres_carres(M)
%
% Fonction de détermination du plan passant au plus proche des points
% donnés au sens des moindres carrés.
%__________________________________________________________________________
%
% Entrées : 
% M : tableau de n points 3D [n,3]
%__________________________________________________________________________
%
% Sorties 1 : 
% Normale : vecteur normal au plan des moindres carrés [1,3]
% Point : point du plan des moindres carrés (barycentre de M) [1,3]
% 
% Sorties 2 :
% Plan : variable de type plan [2,3]
%        Plan(1,:) : point du plan
%        Plan(2,:) : normale au plan
%__________________________________________________________________________

%
% 0. Gestion des données d'entrée
%
if size(M,2) ~= 3 ;
    error('Les données doivent être 3D : M [n,3]') ;
end
if size(M,1) < 3 ;
    error('Il faut au moins 3 points pour calculer un plan') ;
end
%
% 1. Calcul du Point pour le plan des moindres carrés : Barycentre
%
P = barycentre(M) ;
M = M - ones(size(M,1),1) * P ;
%
% 2. Calcul du vecteur normal au plan : 
% vecteur propre de P'*P associé à la plus petite valeur propre
%
[Vectors,ValeursP] = eigs(M'*M) ; % ---> Calcul des vecteurs propres et valeurs propres
ValeursP = diag(ValeursP) ;       % ---> Mise en vecteur
[value,ou] = min(ValeursP) ;      % ---> Recherche du minima
N = Vectors(:,ou) ; N = N' / norm(N) ;
%
% 3. Choix du type de sortie
%
if nargout == 1 ;
    N = [P;N] ;
end
%
% Fin de la fonction