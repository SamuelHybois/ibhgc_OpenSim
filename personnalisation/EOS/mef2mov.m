%% MEF2MOV


%% ENTETE

% Fonction :
% movie = mef2mov(MEF,echo)
%
% Version:     1.0 (année de la version)
% Langage:     Matlab    Version: 7.5
% Plate-forme: PC windows 2000
%___________________________________________________________________________
%
% Niveau de Validation : 3
%
% 0 : en cours de développement, ne fonctionne pas encore
% 1 : fonctionne dans le cadre d'une utilisation precise par le programmeur
%     (risque de disfonctionnement pour une utilisation exterieure)
% 2 : fonctionne dans le cadre d'une utilisation plus ouverte par plusieurs
%     utilisateurs (quelques erreurs possibles mais résultats valides)
% 3 : fonctionne dans tous les cas et donne des résultats valides
%___________________________________________________________________________
%
% Fonction transformant un objet de format MEF en un objet de format MOVIE
%___________________________________________________________________________
%
% Paramètres d'entrée  :
%-----------------------
%
% Format MEF : 2 champs principaux .Noeuds et .Elem
%              dans le .Noeuds : .tag (numérique) .coord (numérique)
%              dans le .Elem : .tag (numérique) .elem (numérique)
%
%
%
% Paramètres de sortie :
%-----------------------
%
% MOVIE : Structure movie
%
%___________________________________________________________________________
%
% Notes :
%___________________________________________________________________________
%
% Fichiers, Fonctions ou Sous-Programmes associés
%
% Appelants :
%
% Appelées :
%___________________________________________________________________________
%
% Mots clefs : Maillage movie
%___________________________________________________________________________
%
% Exemples d'utilisation de la fonction :
%----------------------------------------
%
%___________________________________________________________________________
%
% Auteurs : S LAPORTE
% Date de création : 24/09/2007
% Créé dans le cadre de :  Post-Doc
% Professeur responsable : Laporte
%___________________________________________________________________________
%
% Modifié par :
% le :
% Pour :
% Modif N°1   :
%___________________________________________________________________________
%
% Laboratoire de Biomécanique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'Hôpital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%___________________________________________________________________________
%
% Toutes copies ou diffusions de cette fonction ne peut être réalisée sans
% l'accord du LBM
%___________________________________________________________________________




%% ALGORITHME
%%-------------------------------------------------------------------------
%%------------- 0. Gestion entrée
%%-------------------------------------------------------------------------
%
%%-------------------------------------------------------------------------
%%-------------  I. Traitement des données
%%-------------------------------------------------------------------------
% ### I. Création de la table de correspondances - position / tag ###
% ### II. Renumérotation des éléments                                     ###
% ### IV. Passage de l'écriture NP vers le movie et sauvegarde des tags ###


%% CODE
function MOVIE = mef2mov(MEF)
%%-------------------------------------------------------------------------
%%-------------------------------------------------------------------------
%%------------- 0. Gestion entrée
%%-------------------------------------------------------------------------
%%-------------------------------------------------------------------------
% ---> si Nargin est different de 1 : il n'y a pas le bon nombre d'arguments en entrée
if nargin ~= 1 ;
    error('Nombre de paramètres d''entrée incorrect ...') ;
    % Les données de sortie sont renvoyées vides ...
    MOVIE = [] ;
    return ; % fin de la fonction
end
% verification succinte de la structure du maillage
if ~isfield(MEF,'Noeuds') || ~isfield(MEF,'Elem')
    warning('Mauvais format du maillage !!!')
    MOVIE = [] ;
    return ; % fin de la fonction
end
%%
%%-------------------------------------------------------------------------
%%-------------  I. Traitement des données
%%-------------------------------------------------------------------------
%
% nettoie noeuds inutiles
%
[ind,ia] = intersect(unique(MEF.Elem.elem(:)),MEF.Noeuds.tag) ;
MEF.Noeuds.tag = MEF.Noeuds.tag(ia) ;
MEF.Noeuds.coord = MEF.Noeuds.coord(ia,:) ;
%
% #########################################
% ### I. Création de la table de correspondances - position / tag ###
% #########################################
%
Table_corr = [[1:length(MEF.Noeuds.tag)]',MEF.Noeuds.tag] ;
%
% #########################################
% ### II. Renumérotation des éléments                                     ###
% #########################################
%
%
% b) Mise en forme de la matrice des éléments
%
% #### Attention marche aujourd'hui que pour les modèles à un seul type d'éléments ####
% #### Penser à trouver une méthode pour gérer les multi-éléments                         ####
%
% ---> En vecteur colonne
D = reshape(MEF.Elem.elem,size(MEF.Elem.elem,1)*size(MEF.Elem.elem,2),1) ;
% ---> Tri par ordre croissant des numéros de noeuds
[C,Ix] = sort(D) ; % Ix est tel que C = D(Ix)
% ---> Calcul de l'inverse de Ix
Temp = sortrows([Ix,[1:length(Ix)]']) ;
Iy = Temp(:,2) ; clear Temp ; % Iy est tel que D = C(Iy)
% ---> Définition des positions des différents noeuds & du nombre d'éléments d'appui
ou = [find(diff(C));length(C)] ;            % localisation pour le numéro d'élément
Nel = diff([0;find(diff(C));length(C)]) ; % Nombre d'élément d'appui
%
% c) Renumérotation des n° de noeuds
%
type = unique(Nel) ;  % les différents nombres d'élément d'appui
CC = zeros(size(C)) ; % pour le replissage de la variable de sortie
% ---> Boucle sur le nombre de type
for t = 1:length(type) ;
    % ---> Recherche des numéros de noeuds appartenant à cette clase de type
    liste = ou(find(Nel == type(t))) ;
    % ---> Recherche des numéros de noeuds équivalent pour le movie
    [temp,qui] = intersect(Table_corr(:,2),C(liste)) ;
    qui = Table_corr(qui,1) ;
    % ---> Remplissage de la variable  CC
    for y = 1:type(t) ;
        CC(liste-y+1) = qui ;
    end
end
%
% d) Remise en forme pour la variable de sortie
%
P = reshape(CC(Iy),size(MEF.Elem.elem,1),size(MEF.Elem.elem,2)) ;
%
% nezttoie noeuds inutiles
%


%
% #############################################
% ### IV. Passage de l'écriture NP vers le movie et sauvegarde des tags ###
% #############################################
%
% a) Création du tableau de coordonnées des noeuds + mise au format movie
%
N = MEF.Noeuds.coord ;
MOVIE = NP2mov(N,P) ;
%
% b) Ajout d'informations supplémentaires
%
MOVIE.tag_noeuds = MEF.Noeuds.tag ;
MOVIE.tag_elts = MEF.Elem.tag ;
%%FIN