% [N,P,Info] = nettoie_maillage_NP(N,P) ;
%
% Fonction de nettoyage d'un maillage :
% - Retire les noeuds qui sont hors surface, i.e. qui ne sont sommet d'aucun polygone,
% - Retire les polygones dont la surface est nulle,
% - Triangularise les quadrangles si nécessaire.
% ______________________________________________________________________________________
%
function [N,P,Info,liste_pts_ok] = nettoie_maillage_NP(N,P) ;
%
% 1. Recherches les informations pour les polygones :
%
[Info,P] = analyse_geometrie_polygones(P,N) ; % Calcul des surfaces et triangularisation
%
% 2. Retrait des polygones à surface nulle :
%
Liste_SN = find(Info.Surface == 0) ; % Liste des surfaces à retirer ;
if ~isempty(Liste_SN) ;
    Liste_SN = find2([1:length(Info.Surface)],Liste_SN,'~=') ; % Liste des surfaces ok
    % ---> Mise à jour de la variable Info
    Info.Barycentre = Info.Barycentre(Liste_SN,:) ;      % Mise à jour des barycentres
    Info.Surface = Info.Surface(Liste_SN,:) ;            % Mise à jour des surfaces
    Info.Normale = Info.Normale(Liste_SN,:) ;            % Mise à jour des normales
    % ---> Mise à jour de la variable P
    P = P(Liste_SN,:) ;                                    % Nouvelle définition
end
%
% 3. gestion des noeuds hors surface
%
liste_pts_ok = unique(P) ;
if length(liste_pts_ok) ~= size(N,1) ;
    [N,P] = extrait_points_movie(N,P,liste_pts_ok) ;
end
%
% Fin de la fonction