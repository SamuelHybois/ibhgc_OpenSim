%% MEF2MOV


%% ENTETE

% Fonction :
% movie = mef2mov(MEF,echo)
%
% Version:     1.0 (ann�e de la version)
% Langage:     Matlab    Version: 7.5
% Plate-forme: PC windows 2000
%___________________________________________________________________________
%
% Niveau de Validation : 3
%
% 0 : en cours de d�veloppement, ne fonctionne pas encore
% 1 : fonctionne dans le cadre d'une utilisation precise par le programmeur
%     (risque de disfonctionnement pour une utilisation exterieure)
% 2 : fonctionne dans le cadre d'une utilisation plus ouverte par plusieurs
%     utilisateurs (quelques erreurs possibles mais r�sultats valides)
% 3 : fonctionne dans tous les cas et donne des r�sultats valides
%___________________________________________________________________________
%
% Fonction transformant un objet de format MEF en un objet de format MOVIE
%___________________________________________________________________________
%
% Param�tres d'entr�e  :
%-----------------------
%
% Format MEF : 2 champs principaux .Noeuds et .Elem
%              dans le .Noeuds : .tag (num�rique) .coord (num�rique)
%              dans le .Elem : .tag (num�rique) .elem (num�rique)
%
%
%
% Param�tres de sortie :
%-----------------------
%
% MOVIE : Structure movie
%
%___________________________________________________________________________
%
% Notes :
%___________________________________________________________________________
%
% Fichiers, Fonctions ou Sous-Programmes associ�s
%
% Appelants :
%
% Appel�es :
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
% Date de cr�ation : 24/09/2007
% Cr�� dans le cadre de :  Post-Doc
% Professeur responsable : Laporte
%___________________________________________________________________________
%
% Modifi� par :
% le :
% Pour :
% Modif N�1   :
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




%% ALGORITHME
%%-------------------------------------------------------------------------
%%------------- 0. Gestion entr�e
%%-------------------------------------------------------------------------
%
%%-------------------------------------------------------------------------
%%-------------  I. Traitement des donn�es
%%-------------------------------------------------------------------------
% ### I. Cr�ation de la table de correspondances - position / tag ###
% ### II. Renum�rotation des �l�ments                                     ###
% ### IV. Passage de l'�criture NP vers le movie et sauvegarde des tags ###


%% CODE
function MOVIE = mef2mov(MEF)
%%-------------------------------------------------------------------------
%%-------------------------------------------------------------------------
%%------------- 0. Gestion entr�e
%%-------------------------------------------------------------------------
%%-------------------------------------------------------------------------
% ---> si Nargin est different de 1 : il n'y a pas le bon nombre d'arguments en entr�e
if nargin ~= 1 ;
    error('Nombre de param�tres d''entr�e incorrect ...') ;
    % Les donn�es de sortie sont renvoy�es vides ...
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
%%-------------  I. Traitement des donn�es
%%-------------------------------------------------------------------------
%
% nettoie noeuds inutiles
%
[ind,ia] = intersect(unique(MEF.Elem.elem(:)),MEF.Noeuds.tag) ;
MEF.Noeuds.tag = MEF.Noeuds.tag(ia) ;
MEF.Noeuds.coord = MEF.Noeuds.coord(ia,:) ;
%
% #########################################
% ### I. Cr�ation de la table de correspondances - position / tag ###
% #########################################
%
Table_corr = [[1:length(MEF.Noeuds.tag)]',MEF.Noeuds.tag] ;
%
% #########################################
% ### II. Renum�rotation des �l�ments                                     ###
% #########################################
%
%
% b) Mise en forme de la matrice des �l�ments
%
% #### Attention marche aujourd'hui que pour les mod�les � un seul type d'�l�ments ####
% #### Penser � trouver une m�thode pour g�rer les multi-�l�ments                         ####
%
% ---> En vecteur colonne
D = reshape(MEF.Elem.elem,size(MEF.Elem.elem,1)*size(MEF.Elem.elem,2),1) ;
% ---> Tri par ordre croissant des num�ros de noeuds
[C,Ix] = sort(D) ; % Ix est tel que C = D(Ix)
% ---> Calcul de l'inverse de Ix
Temp = sortrows([Ix,[1:length(Ix)]']) ;
Iy = Temp(:,2) ; clear Temp ; % Iy est tel que D = C(Iy)
% ---> D�finition des positions des diff�rents noeuds & du nombre d'�l�ments d'appui
ou = [find(diff(C));length(C)] ;            % localisation pour le num�ro d'�l�ment
Nel = diff([0;find(diff(C));length(C)]) ; % Nombre d'�l�ment d'appui
%
% c) Renum�rotation des n� de noeuds
%
type = unique(Nel) ;  % les diff�rents nombres d'�l�ment d'appui
CC = zeros(size(C)) ; % pour le replissage de la variable de sortie
% ---> Boucle sur le nombre de type
for t = 1:length(type) ;
    % ---> Recherche des num�ros de noeuds appartenant � cette clase de type
    liste = ou(find(Nel == type(t))) ;
    % ---> Recherche des num�ros de noeuds �quivalent pour le movie
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
% ### IV. Passage de l'�criture NP vers le movie et sauvegarde des tags ###
% #############################################
%
% a) Cr�ation du tableau de coordonn�es des noeuds + mise au format movie
%
N = MEF.Noeuds.coord ;
MOVIE = NP2mov(N,P) ;
%
% b) Ajout d'informations suppl�mentaires
%
MOVIE.tag_noeuds = MEF.Noeuds.tag ;
MOVIE.tag_elts = MEF.Elem.tag ;
%%FIN