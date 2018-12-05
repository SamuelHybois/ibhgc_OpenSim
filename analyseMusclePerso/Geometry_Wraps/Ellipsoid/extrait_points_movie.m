% [M2N,M2P] = extrait_points_movie(M1N,M1P,liste) ;
%
% Fonction qui permet d'extraire des points dans un fichier movie et de suprimer les facettes non
% associ�es. ---> cette fonction ne peut etre utilis�e que sur des movie contenant un seul objet
%
function [M2N,M2P] = extrait_points_movie(M1N,M1P,liste) ;
%
% 0. Gestion des donn�es d'entr�e
%
% ---> Gestion du nombre d'entr�es
if nargin == 2 ;
    M1 = M1N ;
    liste = M1P ;
elseif nargin == 3 ;
    M1.Noeuds = M1N ;
    M1.Polygones = M1P ;
end
% ---> Mise en forme
M1.Polygones = triangularise_maillage(M1.Polygones,M1.Noeuds) ; % Triangularisation
liste = sort(liste) ;        % Mise en ordre croissant des noeuds � conserver
liste2 = [1:length(liste)] ; % Nouveaux num�ros de noeuds
% 
% 1. Recherche des facettes contenant les points d'int�ret :
%
Liste_poly =  reshape(([1:size(M1.Polygones,1)]' * ...
    [1,1,1])',3*size(M1.Polygones,1),1) ;                         % Liste des triangles
Liste_Noeuds = reshape(M1.Polygones',3*size(M1.Polygones,1),1) ;  %    Liste des noeuds
[Liste_Noeuds,ordre] = sortrows(Liste_Noeuds) ; %       Classement des noeuds par ordre
Liste_poly = Liste_poly(ordre) ;                %  R�arrangement des polygones associ�s
% ---> Recherche des noeuds appartenenant � la liste des noeuds � extraire 
[Temp,qui1] = intersect(Liste_Noeuds,liste) ;          % Derniers
[Temp,qui2] = intersect(flipud(Liste_Noeuds),liste) ;  % Premiers
qui2 = 1 + length(Liste_Noeuds) - qui2 ;               % Mise en forme
% ---> D�finition des polygones � conserver
Poly_dep = qui2' ; % Premiers
N_Polys = qui1' - Poly_dep ;      % Nombres de polygones associ�s - 1 par noeud
% ---> Cr�ation des polygones � conserver
C = [] ; % Initialisation de la variable des polygones s'appuyant sur les noeuds donn�s
for t = min(N_Polys):max(N_Polys) ;
    listet = find(N_Polys == t) ; % Recherche des noeuds s'appuyant sur t + 1 polygones  
    U = Poly_dep(listet) ;        % R�cup�ration du premier polygone
    % ---> Construction des listes de polygones pour les noeuds donn�s :
    Mat = U ;
    for y =1:t ;
        Mat = [Mat,U+y] ;
    end
    C = [C;Liste_poly(reshape(Mat',(t+1)*length(listet),1))] ; % Mise en forme
end
% ---> Tri par ordre croissant des num�ros de polygones dans C
C = sort(C) ; 
% ---> Recherche des changements de num�ros de polygones
listet = [0;find(diff(C) ~= 0);length(C)] ;
% ---> Recherche des polygones s'appuyant sur au moins 3 noeuds de la liste
listet = C(1 + listet(find(diff(listet) == 3))) ;
Pol_ok = M1.Polygones(listet,:) ; % D�finitions des polygones � conserver
%
% 2. Modification des d�finition des �l�ments
% ---> Nouvelle liste des polygones
Liste_poly =  [1:3*size(Pol_ok,1)] ;
% ---> Nouvelle liste des noeuds
Liste_Noeuds = reshape(Pol_ok',3*size(Pol_ok,1),1) ;  
% ---> Tri par ordre croissant des num�ros de noeuds
[Liste_Noeuds,ordre] = sortrows(Liste_Noeuds) ;
Liste_poly = Liste_poly(ordre) ;
% ---> Recherche des modifications de num�ros de Noeuds
listet = find(diff(Liste_Noeuds) ~= 0) ;
% ---> Extraction des noeuds r�els du maillage
Noeuds_ok = [Liste_Noeuds(listet);Liste_Noeuds(end)] ; % Noeuds r�els du maillage
[Temp,qui] = intersect(liste,Noeuds_ok) ;
liste2 = liste2(qui)' ;
% ---> Initialisation de la modification des d�finitions
Poly_dep = [1;listet+1] ;                  % Polygones de d�but
Poly_fin = [listet;length(Liste_Noeuds)] ; % Polygones de fin
N_Polys = Poly_fin - Poly_dep ;            % Nombres de polygones associ�s - 1 par noeud
% ---> Modification des d�finitions
warning off
for y = min(N_Polys):max(N_Polys) ;
    listey = find(N_Polys == y) ; % Recherche des noeuds s'appuyant sur y + 1 polygones
    U = Poly_dep(listey) ;        % R�cup�ration du premier polygone
    % ---> Construction des listes de polygones pour les noeuds donn�s :
    Mat = U ;
    for k =1:y ;
        Mat = [Mat,U+k] ;
    end
    % ---> Mise en forme de la nouvelle d�finition des noeuds
    Mat = reshape(Mat',(y+1)*length(listey),1) ;
    Liste_Noeuds(Mat) = reshape(ones(y+1,1) * liste2(listey)',(y+1)*length(listey),1) ;
end
warning on
%
% 3. Ecriture de la variable de sortie
%
[Liste_poly,ordre] = sortrows(Liste_poly') ; % ---> Pour la remise dans l'ordre des noeuds
M2.N_Obj = 1 ;
M2.N_Pts = length(liste) ;
M2.N_Pol = size(Pol_ok,1) ;
M2.N_Arr = 3 * size(Pol_ok,1) ;
M2.Objets = [1,size(Pol_ok,1)] ;
M2.Noeuds = M1.Noeuds(liste,:) ;
M2.Polygones = reshape(Liste_Noeuds(ordre),3,size(Pol_ok,1))' ;
%
% 4. Gestion des sorties
%
if nargout == 1 ;
    M2N = M2 ;
elseif nargout == 2 ;
    M2N = M2.Noeuds ;
    M2P = M2.Polygones ;
end
%
% Fin de la fonction