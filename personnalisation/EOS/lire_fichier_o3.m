% fonction Objet_3D = lire_fichier_o3(nom_o3,M_clefs)
%
% Version:     1.0 (1999)  
% Langage:     Matlab    Version: 5.3
% Plate-forme: PC windows 98
%___________________________________________________________________________
%
% Niveau de Validation : 2
%___________________________________________________________________________
%
% Description de la fonction : fonction permettant la lecture des fichiers 
% au format o3. Il est n�cessaire de pr�ciser les objets que l'on souhaite
% r�cup�rer (un scan_fich peut est r�aliser � cet effet).
%___________________________________________________________________________
%
% Param�tres d'entr�e :
%
% nom_o3 : nom du fichier dont on souhaite r�cup�rer les donn�es
%          chaine de caract�res - string
%
% M_clef: Liste des noms des objets dont on souhaite r�cup�rer les conn�es
%         tableau de chaines de caract�res - cell array {1,N_Obj}
%
% Param�tres de sortie :
%
% Objet_3D : donnees correspondant aux objets � recup�rer
%            Structure multi-pages (N_Obj) contenant les champs :
%           .type : nom de l'objet
%           .tag_num : tableau des tags de num�risation
%                      Tableau de cellules [px1]
%           .coord : coordonn�es 2D des points 
%                    Matrice [px3]
%           .N_Pts : nombre de points pour l'objet
%                    entier - integer
%___________________________________________________________________________
%
% Mots clefs : Fichiers
%___________________________________________________________________________
%
% Auteurs :                S�bastien LAPORTE
% Date de cr�ation :       5 D�cembre 2000
% Cr�� dans le cadre de :  Th�se
% Professeur responsable : W. SKALLI & D. MITTON
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
%
function Krige = lire_fichier_o3(nom_o3,M_clefs)
%
% 1. Ouverture du fichier o3 en lecture seule
%
fid = fopen(nom_o3,'r') ;
%
% 2. Cas o� le fichier ne s'ouvre pas correctement
%
if fid == -1 ;
    msgbox('Probl�me d''ouverture de fichier: le fichier n''existe peut-�tre pas',...
        'Erreur:','error'); 
    Krige = [] ;
    return
end
%
% 3. R�cup�ration du nombre d'objet :
%
N_Obj = size(M_clefs,2) ;
%
% Initialisation des variables de calcul:
%
for y = 1:N_Obj ;
    Krige(y).tag = {} ;
    Krige(y).coord = [] ;
end
%
% R�cup�ration des donn�es : scannage du fichier ...
%
while ~feof(fid); % lecture du fichier en entier
    %
    % ######################################################
    % # 1. lecture d'une ligne compl�te du fichier format� #
    % ######################################################
    %
    ligne = fgetl(fid);
    %
    % #######################################################
    % # 2. Choix de l'action suivant le contenu de la ligne #
    % #######################################################
    %
    % Recherche du type d'objet ...
    %
    if strncmp(ligne,'Objet:',6) ; % ---> il y a un objet � traiter :
        %
        % Identification de l'objet � traiter
        %
        type_objet = sscanf(strrep(ligne,'Objet:',''),'%s',1) ;
        %
        % Recherche de l'indice num�rique associ� � cet objet
        %
        t = find(strcmp(M_clefs,type_objet)==1) ;
        %
        % R�cup�ration des coordonn�es suivant la prise de vue si l'objet est demand�
        %
        if ~isempty(t) 
            %
            Krige(t) = recup_3D(fid,Krige(t));
            %
            % Ecriture du type de l'objet :
            %
            Krige(t).type = M_clefs{t} ;
            Krige(t).N_Pts = length(Krige(t).coord) ; 
        end
    end
end
%
% Il ne faut pas oublier de fermer le fichier
%
fclose(fid) ;
%
% fin de la fonction principale 
%
% ######################################################################################
%
function Obj = recup_3D(fid,Obj) ;
%
% sous fonction permettant la lecture des coordonn�es d'un objet dans un fichier o3
% avec une prise en compte de lignes de commentaires ('#') pour certain point ...
%
% entr�e : fid : file identifier du fichier traiter
%          Obj : structure � remplir avec les champs .tag et .coord
%
% sortie : Obj : structure remplie avec les champs .tag et .coord
%
%_______________________________________________________________________________________
%
% R�cup�ration de l'indice de remplissage de la structure
%
init = size(Obj.tag,1) + 1 ;
%
% Initialisation de la variable de recherche ce Grid ou Lin
%
lecture = 'No' ;
%
% lecture de la ligne contenant les premi�re informations 1er tag et 1eres coordonn�es
%
ligne = fgetl(fid) ;
%
% r�cup�ration des donn�es ...
%
while 1
    %
    % R�cup�ration des informations si il le faut
    %
    if strcmp(lecture,'OK')
        %
        % r�cup�ration de la ligne
        %
        tag_temp = sscanf(ligne,'%s',1) ;            % r�cup�ration du tag temporaire
        tag_temp_ou = findstr(ligne,tag_temp) ;      % localisation du tag temporaire
        if isempty(tag_temp_ou) ;
            break
        end
        % on retire le tag de la ligne
        ligne = ligne(tag_temp_ou(1)+length(tag_temp):end) ;      
        [coor_temp,combien] = sscanf(ligne,'%f',3) ; % r�cup�ration des coordonn�es temporaires
        %
        % si combien == 3 : ce point est valide seulement si tag_temp(1) ~= '#'
        %
        if (combien == 3) & ~(strncmp(tag_temp,'#',1))
            %
            % remplissage de la structure Obj
            %
            Obj.tag{init,1} = tag_temp ;
            Obj.coord(init,1:3) = coor_temp ;
            init = init + 1 ;
        elseif strncmp(tag_temp,'#',1) ;
            % la on ne fait rien on attend le prochain point
        else
            %
            % dans le cas contraire on doit sortir de la boucle while 
            %
            break
            %
        end
    end
    %
    % Recherche des mots clefs Grid_3D ou Lin_3D
    %
    if strncmp(ligne,'Grid_3D:',8)|strncmp(ligne,'Lin_3D:',7) ; 
        %
        % ---> Il y a des donn�es � traiter
        %
        lecture = 'OK' ;
    end
    %
    % Lecture d'une nouvelle ligne
    %
    ligne = fgetl(fid) ;
end
%
%
% fin de la sous fonction