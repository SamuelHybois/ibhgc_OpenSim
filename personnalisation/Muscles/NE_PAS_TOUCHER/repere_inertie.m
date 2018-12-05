% [MI3D,Repere] = repere_inertie(M3D,Poids,option) ;
% [MI3D,Repere] = repere_inertie(M3D,option) ;
% [MI3D,Repere] = repere_inertie(M3D,Poids) ;
%
% Fonction permettant de calculer le repère d'inertie associé à un nuage de points.
% Ce repère est centré sur le barycentre et les axes sont alors les axes principaux
% d'inertie (l'axe x est celui qui à la plus grande inertie propre).
% L'orientattion de ces axes est réalisé en fonction des densités de points par défaut
% ou par les longueurs caractéristiques (grandes valeurs pour les valeurs négatives, 
% faibles valeurs pour les valeurs positives).
% Les options sont : 'densite' ou 'longueur'
%
function [MI3D,Repere] = repere_inertie(MPts,Poids,option) ;
%
% 1. Gestion des données d'entrée :
%
if nargin < 2 ;
    %
    % Pas de poids spécifiés : tous les points ont une masse de 1
    %
    Poids = ones(length(MPts),1) ;
    option = 'densite' ;
end
if nargin == 2 ;
    % ---> On doit chercher à savoir quel type d'information on a en entrée
    if ischar(Poids) ;
        % ---> On a affaire à une option d'orientation :
        option = Poids ;
        Poids = ones(length(MPts),1) ;
    else
        % ---> Ici c'est le poids qui est entré
        option = 'densite' ;
    end
end
if nargin == 3 ;
    if (~strcmp(option,'densite'))&(~strcmp(option,'longueur')) ;
        % ---> Il y a une erreur ...
        % warning et utilisation des densités
        warning('Option inconnue utilisation des densités ...') ;
        option = 'densite' ;
    end
end
%
%
%
P = Poids*ones([1,size(MPts,2)]) ;
%
% 2. Calcul du barycentre pour le nuage de points
%
Repere.OR3D = barycentre(MPts,Poids) ;
%
% 3. Translation des points pour que le barycentre soit le nouveau centre du repère
%
MI3D = MPts - ones(length(MPts),1) * Repere.OR3D ;
%
% 4. Calcul des axes d'inertie par diagonalisation de la matrice d'inertie en G
%
% a) matrice d'inertie en O dans le repère de départ
%
Mat_poids = MI3D.*P ;
Mat_inertie = eye(size(MPts,2))*trace(Mat_poids'*MI3D) - Mat_poids'*MI3D ;
%
% b) recherche des valeurs propres et des vecteurs propres pour cette matrice
%
[Vecteurs,Matrice] = eigs(Mat_inertie) ;
%
% c) classement des axes : de la valeur propre la plus élevée à la plus faible
%
[N,ordre] = sortrows(diag(Matrice)) ; % pour avoir l'ordre des valeurs propres
ordre = ordre([length(ordre):-1:1]) ; % pour l'ordre décroissant
Vecteurs = Vecteurs(:,ordre) ;        % pour les axes propres
%
% 5. Orientation des axes ...
%
% Traitement suivant la dimension de l'espace :
%
if size(MPts,2) == 3 ; % Cas 3D
    %
    % 5.1 Pour l'axe Z (plus petite valeur inertielle)
    %
    % a) Calcul des densités et longueurs autour du barycentre dans la direction Z
    %
    droite_Z.pts = Repere.OR3D ; droite_Z.V_dir = Vecteurs(:,3)' ;
    Z_densite = calcul_densite_axe(droite_Z,MPts,Poids) ;
    %
    % b) Réorientation de l'axe si nécessaire suivant l'option choisie
    %
    switch option
    case 'densite' ;    
        if (Z_densite.positif - Z_densite.negatif) > 10e-6 ;
            % On doit inverser l'axe
            Vecteurs(:,3) = - Vecteurs(:,3) ;
        end
    case 'longueur' ;
        if (Z_densite.opositif - Z_densite.onegatif) > 10e-6 ;
            % On doit inverser l'axe
            Vecteurs(:,3) = - Vecteurs(:,3) ;
        end
    end
    %
    % 5.2 Pour l'axe Y (seconde inertie)
    %
    % a) Calcul des densité autour du barycentre dans la direction Y
    %
    droite_Y.pts = Repere.OR3D ; droite_Y.V_dir = Vecteurs(:,2)' ;
    Y_densite = calcul_densite_axe(droite_Y,MPts,Poids) ;
    %
    % b) Réorientation de l'axe si nécessaire suivant l'option choisie
    %
    switch option
    case 'densite' ;    
        if (Y_densite.positif - Y_densite.negatif) > 10e-6 ;
            % On doit inverser l'axe
            Vecteurs(:,2) = - Vecteurs(:,2) ;
        end
    case 'longueur' ;
        if (Y_densite.opositif - Y_densite.onegatif) > 10e-6 ;
            % On doit inverser l'axe
            Vecteurs(:,2) = - Vecteurs(:,2) ;
        end
    end
    %
    % 5.3 l'axe X est déduit par un produit vectoriel de Y avec Z
    %
    Vecteurs(:,1) = cross(Vecteurs(:,2),Vecteurs(:,3)) ;
    %
elseif size(MPts,2) == 2 ; % Cas 2D
    %
    % 5.1 Pour l'axe Y (plus petite valeur inertielle)
    %
    % a) Calcul des densités et longueurs autour du barycentre dans la direction Y
    %
    droite_Y.pts = Repere.OR3D ; droite_Y.V_dir = Vecteurs(:,2)' ;
    Y_densite = calcul_densite_axe(droite_Y,MPts,Poids) ;
    %
    % b) Réorientation de l'axe si nécessaire suivant l'option choisie
    %
    switch option
    case 'densite' ;    
        if (Y_densite.positif - Y_densite.negatif) > 10e-6 ;
            % On doit inverser l'axe
            Vecteurs(:,2) = - Vecteurs(:,2) ;
        end
    case 'longueur' ;
        if (Y_densite.opositif - Y_densite.onegatif) > 10e-6 ;
            % On doit inverser l'axe
            Vecteurs(:,2) = - Vecteurs(:,2) ;
        end
    end
    %
    % 5.2 Pour l'axe Y (réorientation pour obtenir une base directe)
    %
    if (Vecteurs(1,1)*Vecteurs(2,2) - Vecteurs(2,1)*Vecteurs(2,1)) < 0 ;
        Vecteurs(:,1) = - Vecteurs(:,1) ;
    end
end
%
% 6. Sauvegarde de la matrice de changement de base & des inerties propres
%
Repere.MR2DRIN = Vecteurs' ;
Matrice = diag(Matrice); Repere.Inerties = Matrice(ordre) ;
%
% 7. Changement de base pour les points de M3ID
%
MI3D = (Repere.MR2DRIN * MI3D')' ;
%
% Fin de la fonction