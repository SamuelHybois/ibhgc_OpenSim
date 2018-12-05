%
% Fonction permettant de r�cup�rer les informations ponctuelles et surfaciques
% dans un fichier wrml ---> wrml simple (dictionnaire d'@sterX)
%
function A = lire_fichier_wrml(nom_fich) ;
%
% 0. Ouverture du fichier
%
fid = fopen(nom_fich,'r') ;
%
% 1. Nombre d'objets dans le fichier : par d�faut pour cette version on en aura 1 seul
% 
A.N_Obj = 1 ;
%
% 2. R�cup�ration des points
%
% a) recherche de 'point [' : d�but de la d�finition des coordonn�es des points 3D
%
[a,b]=strtok(fgetl(fid));

while ~strncmp(a,'point',5) ;
    % Pour placer notre curseur � la bonne ligne
    [a,b]=strtok(fgetl(fid));
end

if length(b)== 0 ;
    b=strtok(fgetl(fid));
end

[b,c]=strtok(b);

if strncmp(b,'[',1);
    cmpt = 1 ;  % compteur de points
    %
    % b) r�cup�ration des informations de coordonn�es
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
        % recherche des coordonn�es �ventuelles
        [temp_coord,lu] = sscanf(ligne,'%f',3) ;
        % sauvegarde de ces donn�es si elles sont au nombree de 3
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
    % 3. R�cup�ration des Polygones ...
    %
    fid = fopen(nom_fich,'r') ;
    %
    % a) recherche de 'coordIndex [' : d�but de la d�finition des polygones
    %
    [a,b]=strtok(fgetl(fid));

    while ~strncmp(a,'coordIndex',10) ;
        % Pour placer notre curseur � la bonne ligne
        [a,b]=strtok(fgetl(fid));
    end

    if length(b)==0 ;
        b=strtok(fgetl(fid));
    end

    [b,c]=strtok(b);

    if strncmp(b,'[',1);
    
    %
    % b) r�cup�ration des donn�es li�es aux polygones
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
                % Recherche si on a affaire � un triangle ou � un quadrangle
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
 
            % extraction des donn�es relatives
            if isempty(findstr(ligne,',')) ;
            
            else
                ligne=strrep(ligne, ',', ' ');
            end
            
            [Temp,combien] = sscanf(ligne,'%f',5) ;

            % sauvegarde des donn�es si n�cessaire
            if combien > 0 ;
                A.Polygones(cmpt,1:combien-1) = Temp(1:combien-1)' + 1 ;
                cmpt = cmpt + 1 ;
                % Recherche si on a affaire � un triangle ou � un quadrangle
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
        error('Probl�me d ecriture du fichier au niveau de CoordIndex /n Impossible � analyser - Veuillez verifier le format du fichier');
    end        
else
    error('Probl�me d ecriture du fichier au niveau des points /n Impossible � analyser - Veuillez verifier le format du fichier');
end
%
% A. Fermeture du fichier :
%
fclose(fid) ;
%
% Fin de la fonction