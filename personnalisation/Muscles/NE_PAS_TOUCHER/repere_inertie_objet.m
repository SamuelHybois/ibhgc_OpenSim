%
% Fonction de mise en rep�re d'inertie d'un objet :
%
% function [Objet,Repere] = repere_inertie_objet(Objet) ;
%
% ---> Objet de type mesure : Poids egaux en tous les points
% ---> Objet de type movie  : Poids �gaux aux surfaces des polygones en leurs centre d'inertie
%
function [Objet] = repere_inertie_objet(Objet) ;
%
% ___ Il faut traiter les cas suivant mes ou movie ___
%
if isfield(Objet,'Polygones')
    if ~isempty(Objet.Polygones) ;
        %
        % C'est le cas des objets de type movie ...
        %
        % ---> Utilisation des informations li�es aux surfaces
        %
        % [I,Objet.RI] = inertie_movie(Objet.Noeuds,Objet.Polygones) ;
        Info = analyse_geometrie_polygones(Objet.Polygones,Objet.Noeuds) ;
        [Temp,Objet.RI] = repere_inertie(Info.Barycentre,Info.Surface) ;
        %
        % ---> Transfert de l'objet dans son rep�re inertiel
        %
        Objet.Noeuds = Objet.Noeuds - ones(length(Objet.Noeuds),1) * Objet.RI.OR3D ; % Translation
        Objet.Noeuds = (Objet.RI.MR2DRIN * Objet.Noeuds')' ;                         % Rotation
    else
        %
        % C'est un fichier de type movie mais sans d�finition de polygone (formta mes dans comp2001)
        %
        [Objet.Noeuds,Objet.RI] = repere_inertie(Objet.Noeuds) ;
    end
else
    %
    % Cas des objets de type mesure
    %
    [Objet.coord,Objet.RI] = repere_inertie(Objet.coord) ;
end
%
% Fin de la fonction