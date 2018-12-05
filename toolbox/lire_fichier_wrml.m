%
% Fonction permettant de récupérer les informations ponctuelles et surfaciques
% dans un fichier wrml ---> wrml simple (dictionnaire d'@sterX)
%
function A = lire_fichier_wrml(nom_fich) ;
%
% 0. Ouverture du fichier
%
fid = fopen(nom_fich,'r') ;
%
% 1. Nombre d'objets dans le fichier : par défaut pour cette version on en aura 1 seul
% 
A.N_Obj = 1 ;
%
% 2. Récupération des points
%
% a) recherche de 'point [' : début de la définition des coordonnées des points 3D
%
[a,b]=strtok(fgetl(fid));

while ~strncmp(a,'point',5) ;
    % Pour placer notre curseur à la bonne ligne
    [a,b]=strtok(fgetl(fid));
end

if length(b)== 0 ;
    b=strtok(fgetl(fid));
end

[b,c]=strtok(b);

if strncmp(b,'[',1);
    cmpt = 1 ;  % compteur de points
    %
    % b) récupération des informations de coordonnées
    %
    if length(c)~=0 ;
        [temp_coord,lu] = sscanf(c,'%f',3) ;
        if lu == 3 ;
            A.Noeuds(cmpt,:) = temp_coord ;
            cmpt = cmpt + 1 ;
        end
    end

    while 1 ;
        % lecture d'une ligne
        ligne = fgetl(fid) ;
        % recherche des coordonnées éventuelles
        [temp_coord,lu] = sscanf(ligne,'%f',3) ;
        % sauvegarde de ces données si elles sont au nombree de 3
        if lu == 3 ;
            A.Noeuds(cmpt,:) = temp_coord ;
            cmpt = cmpt + 1 ;
        else
            break
        end
    end
    %
    % c) calcul du nombre de Noeuds
    % 
    A.N_Pts = cmpt - 1 ;
   
    %
    % 3. Récupération des Polygones ...
    %
    fid = fopen(nom_fich,'r') ;
    %
    % a) recherche de 'coordIndex [' : début de la définition des polygones
    %
    [a,b]=strtok(fgetl(fid));

    while ~strncmp(a,'coordIndex',10) ;
        % Pour placer notre curseur à la bonne ligne
        [a,b]=strtok(fgetl(fid));
    end

    if length(b)==0 ;
        b=strtok(fgetl(fid));
    end

    [b,c]=strtok(b);

    if strncmp(b,'[',1);
    
    %
    % b) récupération des données liées aux polygones
    %
        cmpt = 1 ; % compteur de polygones
        N_tri = 0 ; % calcul du nombre de triangles
        N_qua = 0 ; % calcul du nombre de quadrangles

        if length(c)~=0 ;
            if isempty(findstr(c,',')) ;
                
            else
                c=strrep(c, ',', ' ');
            end
            [Temp,combien] = sscanf(c,'%f',5) ;
        
            if combien > 0 ;
                A.Polygones(cmpt,1:combien-1) = Temp(1:combien-1)' + 1 ;
                cmpt = cmpt + 1 ;
                % Recherche si on a affaire à un triangle ou à un quadrangle
                if (combien-1) == 3 ;
                    N_tri = N_tri + 1 ; % cas du triangle
                elseif (combien-1) == 4 ;
                    N_qua = N_qua + 1 ; % cas du quadrangle
                end
            end
        end
 
        while 1
            % lecture d'une ligne
            ligne = fgetl(fid) ;
 
            % extraction des données relatives
            if isempty(findstr(ligne,',')) ;
            
            else
                ligne=strrep(ligne, ',', ' ');
            end
            
            [Temp,combien] = sscanf(ligne,'%f',5) ;

            % sauvegarde des données si nécessaire
            if combien > 0 ;
                A.Polygones(cmpt,1:combien-1) = Temp(1:combien-1)' + 1 ;
                cmpt = cmpt + 1 ;
                % Recherche si on a affaire à un triangle ou à un quadrangle
                if (combien-1) == 3 ;
                    N_tri = N_tri + 1 ; % cas du triangle
                elseif (combien-1) == 4 ;
                    N_qua = N_qua + 1 ; % cas du quadrangle
                end
            else
                break
            end
        end
        %
        % c) Nombre de Polygones :
        %
        A.N_Pol = cmpt - 1 ;
        %
        % d) Nombre d'arretes
        %
        A.N_Arr = 3*N_tri + 4*N_qua ;
        %
        % e) Polygones de l'objet (simple ici)
        %
        A.Objets = [1,A.N_Pol] ;
    else
        error('Problème d ecriture du fichier au niveau de CoordIndex /n Impossible à analyser - Veuillez verifier le format du fichier');
    end        
else
    error('Problème d ecriture du fichier au niveau des points /n Impossible à analyser - Veuillez verifier le format du fichier');
end
%
% A. Fermeture du fichier :
%
fclose(fid) ;
%
% Fin de la fonction