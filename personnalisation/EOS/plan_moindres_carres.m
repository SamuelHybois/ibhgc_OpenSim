function [N,P] = plan_moindres_carres(M)
%
% [Normale,Point] = plan_moindres_carres(M)
% Plan = plan_moindres_carres(M)
%
% Fonction de d�termination du plan passant au plus proche des points
% donn�s au sens des moindres carr�s.
%__________________________________________________________________________
%
% Entr�es : 
% M : tableau de n points 3D [n,3]
%__________________________________________________________________________
%
% Sorties 1 : 
% Normale : vecteur normal au plan des moindres carr�s [1,3]
% Point : point du plan des moindres carr�s (barycentre de M) [1,3]
% 
% Sorties 2 :
% Plan : variable de type plan [2,3]
%        Plan(1,:) : point du plan
%        Plan(2,:) : normale au plan
%__________________________________________________________________________

%
% 0. Gestion des donn�es d'entr�e
%
if size(M,2) ~= 3 ;
    error('Les donn�es doivent �tre 3D : M [n,3]') ;
end
if size(M,1) < 3 ;
    error('Il faut au moins 3 points pour calculer un plan') ;
end
%
% 1. Calcul du Point pour le plan des moindres carr�s : Barycentre
%
P = barycentre(M) ;
M = M - ones(size(M,1),1) * P ;
%
% 2. Calcul du vecteur normal au plan : 
% vecteur propre de P'*P associ� � la plus petite valeur propre
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