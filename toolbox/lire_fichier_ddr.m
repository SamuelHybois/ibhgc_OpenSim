%
% Fonction de lecture d'un fichier au format 
% d�finition de surfaces (.ddr)
%
function Regions = lire_fichier_ddr(nomfich) ;
%
% 1. Ouverture du fichier
%
fid = fopen(nomfich,'r') ;
%
% 2. R�cup�ration des diff�rentes r�gions d'�tude
%
test_reg = 0 ; % indice de traitement des r�gions
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
        % On peut donc r�cup�rer les noms de toutes les r�gions souhait�es
        test_reg = 1 ; % On pourra alors r�cup�rer les noms des points
        cmpt = 0 ;     % compteur de r�gion 
        while 1 ;
            % ---> Lecture d'une nouvelle ligne :
            ligne = fgetl(fid) ;
            % ---> R�cup�ration de la r�gion ou fin de la r�cup�ration
            if strncmp(ligne,'#',1) ;
                break
            else
                % ---> ajout de la r�gion
                cmpt = cmpt + 1 ;
                Regions(cmpt).nom = sscanf(ligne,'%s',1) ;
            end
        end
        % On liste maintenant les diff�rentes r�gions
        liste_region = extract_field(Regions,'nom') ;
        %
    elseif (test_reg == 1) 
        % On doit v�rifier que l'on a bien affaire � une r�gion list�e
        ou = strmatch(sscanf(ligne,'%s',1),liste_region,'exact') ;
        if ~isnan(ou)|~isempty(ou) ;
            % ---> On peut donc r�cup�rer les diff�rents points pour cette r�gion
            cmpt = 0 ; % compteur de points par r�gion
            while 1 ;
                % ---> Lecture d'une nouvelle ligne :
                ligne = fgetl(fid) ;
                % ---> R�cup�ration de la r�gion ou fin de la r�cup�ration
                if strncmp(ligne,'#',1) ;
                    break
                else
                    % ---> ajout de la r�gion
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