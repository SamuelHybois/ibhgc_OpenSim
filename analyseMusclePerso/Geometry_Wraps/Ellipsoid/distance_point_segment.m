% Fonction :   [d,point] = distance_point_segment(segment,M) ; 
%
% Version:     1.0 (2000)  
% Langage:     Matlab    Version: 5.3
% Plate-forme: PC windows 98
%___________________________________________________________________________
%
% Niveau de Validation : 1
%___________________________________________________________________________
%
% Description de la fonction : Fonction permettant de calculer la distance 
% entre un point et un segment d�fini par ces deux points extr�mit�s.
%___________________________________________________________________________
%
% Param�tres d'entr�e  : 
%
% Segment : D�finition du segment par ses deux extr�mit�s
% Matrice de r�els - Real Array (2,n) avec n la dimension de l'espace
%
% M : Point dont on veut conna�tre la distance au segment
% Vecteur de r�els - Real Vector (1,n)
%
% Param�tres de sortie : 
%
% d : valeur de la distance point segment
% Re�l positif - positive real
%
% point : Coordonn�es du point le plus proche de M appartenant au segment
% Vecteur de r�els - Real Vector (1,n)
%___________________________________________________________________________
%
% Mots clefs : G�om�trie 
%___________________________________________________________________________
%
% Auteurs :          S�bastien LAPORTE
% Date de cr�ation : 25 Avril 2000
% Cr�� dans le cadre de : Th�se
% Professeur responsable : W.Skalli & D.Mitton
%___________________________________________________________________________
%
% Laboratoire de Biom�canique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'H�pital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%___________________________________________________________________________
%
% Toutes copies ou diffusions de cette fonction ne peut �tre r�alis�e sans
% l'accord du LBM
%___________________________________________________________________________
%
function [d,point] = distance_point_segment(segment,M) ;
%
% Calcul du vecteur directeur norm� du segment
%
vecteur_directeur = (segment(2,:) - segment(1,:))/norm(segment(2,:) - segment(1,:)) ;
%
% Calcul du produit vectoriel entre le vecteur extr�mit� 1 du segment point M et le
% vecteur directeur du segment
%
gamma = sum((M - segment(1,:)).*vecteur_directeur) ;
%
% traitement des cas suivant la valeur de gamma
%
if gamma <= 0 ; % point � gauche du segment
   %
   d = norm(M - segment(1,:)) ; % distance entre point 1 et M 
   point = segment(1,:) ;       % le point le plus proche est le point 1
   %
elseif gamma >= norm(segment(2,:) - segment(1,:)) ; % point � droite du segment
   %
   d = norm(M - segment(2,:)) ; % distance entre point 2 et M
   point = segment(2,:) ;       % le point le plus proche est le point 2
   %
else % cas ou la projection est dans le segment 1 2 
   %
   point = segment(1,:) + gamma * vecteur_directeur ; % point le plus proche est entre I et J 
   d = norm(M - point) ;                              % distance du point au segment
end
%
% La distance est donn�e avec 3 chiffres significatifs
%
d = fix(1000 * d) / 1000 ;
%
% fin de la fonction