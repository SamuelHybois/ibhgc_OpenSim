function [Liste_repertoires,Liste_fichiers] = PathContent(Path_Directory)
%% Revoie la liste des r�pertoires ainsi que la liste des fichiers contenus dans un r�pertoire
% 
% Entree : Path_Directory : chemin d�finissant le dossier � analyser
% Sorties : 
%   Liste_repertoires: cellule contenant (en colonne) les noms des dossiers contenus dans le dossier analys�
%   Liste_fichiers: cellule contenant (en colonne) les noms des fichiers contenus dans le dossier analys�
%
% Sauret Christophe - Juin 2014
%%

List = dir(Path_Directory);
Liste_repertoires = {}; Liste_fichiers={}; j=0; k=0;

    for i=1:size(List,1)

        if strcmp(List(i).name,'.')==1 || strcmp(List(i).name,'..')==1
            % on fait rien
        elseif List(i).isdir == 1
            j=j+1;
            Liste_repertoires{j,1} = List(i).name ;
        else
            k=k+1;
            Liste_fichiers{k,1} = List(i).name;
        end

    end
end

