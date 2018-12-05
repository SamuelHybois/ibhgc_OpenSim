% function densite = calcul_densite_axe(Droite,MPts,Poids) ;
%
% Cette fonction permet de calculer la densit� de points dans une direction donn�e, par rapport 
% � 2 demi-espaces.
%
function densite = calcul_densite_axe(Droite,MPts,Poids) ;
%
% 0. gestion des donn�es d'entr�es
%
if nargin == 2 ;
    %
    % Pas de poids sp�cifi�s : tous les points ont une masse de 1
    %
    Poids = ones(length(MPts),1) ;
end 
%
% 1. Calcul des vecteurs entre tous les points et l'origine de la droite
%
M_Vecteurs = MPts - ones(length(MPts),1) * Droite.pts ;
%
% 2. Calcul des produits scalaires avec le vecteur directeur de la droite
%
P_scalaire = dot(M_Vecteurs,ones(length(MPts),1) * Droite.V_dir,2) ;
%
% 3. Recherche des bornes pour les projections sur la droite (min et max du scalaire)
%
% a) Calcul des densit�s max ou min
%
densite.nmax = max(P_scalaire) ; densite.nmin = min(P_scalaire) ;
%
% b) Cas o� les densit� sont �gales
%
if (densite.nmax - densite.nmin) < 10e-6 ;
    % distance orthogonale
    densite.opositif = max(sqrt(sum(((M_Vecteurs-P_scalaire * Droite.V_dir).^2)')')) ;
    densite.opositif = max(sqrt(sum(((M_Vecteurs-P_scalaire * Droite.V_dir).^2)')')) ;
    % densit�s
    densite.positif = sum(Poids) / (abs(densite.nmax) * densite.opositif) ;
    densite.negatif = sum(Poids) / (abs(densite.nmin) * densite.opositif) ;
else
    %
    % 4. Calcul des densit�s proprement dite
    %
    % b) Recherche des points en positif et en n�gatif :
    %
    P_positif = find(P_scalaire > 0) ; P_negatif = find(P_scalaire <= 0) ;
    %
    % c) Recherche de la plus grande distance orthogonale � l'axe 
    %
    densite.opositif = max(sqrt(sum(((M_Vecteurs(P_positif,:)-P_scalaire(P_positif) * Droite.V_dir).^2)')'));
    densite.onegatif = max(sqrt(sum(((M_Vecteurs(P_negatif,:)-P_scalaire(P_negatif) * Droite.V_dir).^2)')'));
    %
    % d) masse en positif, masse en n�gatif
    %
    M_positif = sum(Poids(P_positif)) ; M_negatif = sum(Poids(P_negatif)) ;
    %
    % c) densit�s :
    %
    densite.positif = M_positif / (abs(densite.nmax) * densite.opositif);
    densite.negatif = M_negatif / (abs(densite.nmin) * densite.onegatif);
end
%
% Fin de la fonction