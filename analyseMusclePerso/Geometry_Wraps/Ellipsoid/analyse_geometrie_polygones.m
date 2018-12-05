% [Info_Polygones,Polygones] = analyse_geometrie_polygones(Polygones,Noeuds)
%
% Calcule pour chacun des polygones :
% - l'isobarycentre
% - la surface
% - la normale au barycentre
%
% ---> Attention cette fonction triangularise le maillage si nécessaire, c.à.d.
%      transforme les quadrangles en triangles minimisant la distance des tiangles
%      à la surface des quadrangles.
%
function [Info,P] = analyse_geometrie_polygones(P,N) ;
%
% 1. Analyse du maillage : triangularisation si nécessaire
%
Dim = size(P,2) ; % Dimension des polygones
if Dim == 4 ;
    %warning('Les quadrangles sont transformés en triangles') ;
    if nargout == 1 ;
        %warning('Les modifications du maillage ne seront pas sauvegardées') ;
    end
    P = triangularise_maillage(P,N) ;
end
%
% 2. Calcul des barycentres
%
Info.Barycentre = [N(P(:,1),1) + N(P(:,2),1) + N(P(:,3),1),...
        N(P(:,1),2) + N(P(:,2),2) + N(P(:,3),2),...
        N(P(:,1),3) + N(P(:,2),3) + N(P(:,3),3)] / 3 ;
%
% 3. Calcul des surfaces et des vecteurs normaux
%
warning off ;
P_Vect = cross(N(P(:,1),:)-N(P(:,2),:),N(P(:,1),:)-N(P(:,3),:)) ;
Info.Surface = 0.5 * Norm2(P_Vect) ;
Info.Normale = P_Vect ./ ((Info.Surface * ones(1,3)) * 2) ;
warning on ;
%
% Fin de la fonction