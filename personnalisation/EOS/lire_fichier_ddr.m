%
% Fonction de lecture d'un fichier au format 
% définition de surfaces (.ddr)
%
function Regions = lire_fichier_ddr(nomfich) ;
%
% 1. Ouverture du fichier
%
fid = fopen(nomfich,'r') ;
%
% 2. Récupération des différentes régions d'étude
%
test_reg = 0 ; % indice de traitement des régions
%
% ----> scan du fichier
%
while ~feof(fid) ;
    %
    % ---> Lecture d'une ligne du fichier
    %
    ligne = fgetl(fid) ;
    %
    % ---> Traitement des divers cas
    %
    if strncmp(ligne,'Regions:',8) ;
        % On peut donc récupérer les noms de toutes les régions souhaitées
        test_reg = 1 ; % On pourra alors récupérer les noms des points
        cmpt = 0 ;     % compteur de région 
        while 1 ;
            % ---> Lecture d'une nouvelle ligne :
            ligne = fgetl(fid) ;
            % ---> Récupération de la région ou fin de la récupération
            if strncmp(ligne,'#',1) ;
                break
            else
                % ---> ajout de la région
                cmpt = cmpt + 1 ;
                Regions(cmpt).nom = sscanf(ligne,'%s',1) ;
            end
        end
        % On liste maintenant les différentes régions
        liste_region = extract_field(Regions,'nom') ;
        %
    elseif (test_reg == 1) 
        % On doit vérifier que l'on a bien affaire à une région listée
        ou = strmatch(sscanf(ligne,'%s',1),liste_region,'exact') ;
        if ~isnan(ou)|~isempty(ou) ;
            % ---> On peut donc récupérer les différents points pour cette région
            cmpt = 0 ; % compteur de points par région
            while 1 ;
                % ---> Lecture d'une nouvelle ligne :
                ligne = fgetl(fid) ;
                % ---> Récupération de la région ou fin de la récupération
                if strncmp(ligne,'#',1) ;
                    break
                else
                    % ---> ajout de la région
                    cmpt = cmpt + 1 ;
                    Regions(ou).tag{cmpt,1} = sscanf(ligne,'%s',1) ;
                end
            end
        end
    end
end
%
% 3. Fermeture du fichier
%
fclose(fid) ;
%
% fin de la fonction