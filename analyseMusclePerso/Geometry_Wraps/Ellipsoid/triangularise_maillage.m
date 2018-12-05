%
% Fonction transformant les quadrangles en 2 triangles ...
% Attention ceci modifie l'ordre des polygones !!!!!!
%
function P = triangularise_maillage(P,N) ;
%
% 1. Recherche des quadrangles ...
%
Dim = size(P,2) ; % Dimension des polygones
if Dim == 3 ;
    % ---> Il n'y a pas de modification à faire sur les polygones
    return 
end
qua = find(P(:,4) ~= 0) ;
tri = find(P(:,4) == 0) ;
%
% 2. Détermination des triangles à réaliser
%
mH = 0.5 * ( N(P(qua,1),:) + N(P(qua,3),:)) ; % Barycentres AC
mK = 0.5 * ( N(P(qua,2),:) + N(P(qua,4),:)) ; % Barycentres BD
KH = mH - mK ; % ---> Vecteurs entre les deux barycentres
AC = - N(P(qua,1),:) + N(P(qua,3),:) ; % Vecteur AC
BD = - N(P(qua,2),:) + N(P(qua,4),:) ; % Vecteur BD
% ---> Recherche du segment optimal pour la découpe du quadrangle
type = sign((sum(KH.*BD,2)./norm2(BD)).^2 - (sum(KH.*AC,2)./norm2(AC)).^2) ;
% 
% 3. Création des nouveaux triangles
%
tBD = find(type >= 0) ; % Pour les découpes par BD
tAC = find(type < 0)  ; % Pour les découpes par AC
% Pour BD
PBD_1 = [P(qua(tBD),1),P(qua(tBD),2),P(qua(tBD),4)] ;
PBD_2 = [P(qua(tBD),2),P(qua(tBD),3),P(qua(tBD),4)] ;
% Pour AC
PAC_1 = [P(qua(tAC),1),P(qua(tAC),2),P(qua(tAC),3)] ;
PAC_2 = [P(qua(tAC),3),P(qua(tAC),4),P(qua(tAC),1)] ;
%
% 4. Matrice des polygones finaux :
%
P = [P(tri,1:3);PBD_1;PBD_2;PAC_1;PAC_2] ;
%
% Fin de la fonction