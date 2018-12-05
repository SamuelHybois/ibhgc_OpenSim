function chemrel = chemin_relatif_OS(chemin1, chemin2)

% Objectif
%     - crée chemin relatif pour passer du répertoire 1 au répertoire 2 à partir de
%     deux chemins absolus
%
% En entrée:
%   - chemin1 : chaine de caractère contenant le chemin absolu d'un
%       répertoire. ex: d:\manip\sujet1
%   - chemin2 : chaine de caractère contenant le chemin absolu d'un
%       répertoire. ex: d:\manip\sujet2\test
%
% En sortie :
%   - chemrel : chemin relatif pour passer du chemin1  vers le chemin2
%       ex: ..\sujet2\test

chemin1s = strsplit(chemin1, filesep);   % séparation de chaque répertoire
chemin2s = strsplit(chemin2, filesep);

if strcmp(strcat(chemin1s{:}),strcat(chemin2s{:}))==1 % les deux chemins sont identiques
    chemrel = '';
else
    A=min([length(chemin1s),length(chemin2s)]);
    
    % Partie_1 - obj : enlever la partie de chemin1 non-commun à chemin 2
    if length(chemin1s)>length(chemin2s) % cas ou la chemin1 est plus long que le chemin2
        nb_rep_retour = length(chemin1s)-find(strcmp(chemin1s(1:A),chemin2s(1:A))==1,1,'last'); % nombre de repértoire à remonter
        Partie_1 = repmat('..\', 1, nb_rep_retour);
    elseif length(chemin1s)==length(chemin2s)
        nb_rep_retour = length(chemin1s)-find(strcmp(chemin1s(1:A),chemin2s(1:A))~=1,1,'last');
        Partie_1 = repmat('..\', 1, (nb_rep_retour+1));
    elseif find(strcmp(chemin1s(1:A),chemin2s(1:A))==1,1,'last')==length(chemin1s) % cas ou chemin1 est plus petit que chemin2 + le dernier repertoire commun est à la même place
        Partie_1='';
    else
        nb_rep_retour = length(chemin1s)-find(strcmp(chemin1s(1:A),chemin2s(1:A))==1,1,'last');
        Partie_1 = repmat('..\', 1, nb_rep_retour);
    end
    
    % Partie 2 - obj : ajouter la partie de chemin2 non commune à chemin 1
    Partie_2 = chemin2s(find(strcmp(chemin1s(1:A),chemin2s(1:A))==0,1,'last'):end);
    
    chemrel = fullfile(Partie_1, Partie_2{:},filesep);
end

end % end function