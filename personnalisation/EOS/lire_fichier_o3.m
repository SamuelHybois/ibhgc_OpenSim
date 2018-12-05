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
% au format o3. Il est nécessaire de préciser les objets que l'on souhaite
% récupérer (un scan_fich peut est réaliser à cet effet).
%___________________________________________________________________________
%
% Paramètres d'entrée :
%
% nom_o3 : nom du fichier dont on souhaite récupérer les données
%          chaine de caractères - string
%
% M_clef: Liste des noms des objets dont on souhaite récupérer les connées
%         tableau de chaines de caractères - cell array {1,N_Obj}
%
% Paramètres de sortie :
%
% Objet_3D : donnees correspondant aux objets à recupérer
%            Structure multi-pages (N_Obj) contenant les champs :
%           .type : nom de l'objet
%           .tag_num : tableau des tags de numérisation
%                      Tableau de cellules [px1]
%           .coord : coordonnées 2D des points 
%                    Matrice [px3]
%           .N_Pts : nombre de points pour l'objet
%                    entier - integer
%___________________________________________________________________________
%
% Mots clefs : Fichiers
%___________________________________________________________________________
%
% Auteurs :                Sébastien LAPORTE
% Date de création :       5 Décembre 2000
% Créé dans le cadre de :  Thèse
% Professeur responsable : W. SKALLI & D. MITTON
%___________________________________________________________________________
%
% Laboratoire de Biomécanique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'Hôpital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%___________________________________________________________________________
%
% Toutes copies ou diffusions de cette fonction ne peut être réalisée sans
% l'accord du LBM
%___________________________________________________________________________
%
function Krige = lire_fichier_o3(nom_o3,M_clefs)
%
% 1. Ouverture du fichier o3 en lecture seule
%
fid = fopen(nom_o3,'r') ;
%
% 2. Cas où le fichier ne s'ouvre pas correctement
%
if fid == -1 ;
    msgbox('Problème d''ouverture de fichier: le fichier n''existe peut-être pas',...
        'Erreur:','error'); 
    Krige = [] ;
    return
end
%
% 3. Récupération du nombre d'objet :
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
% Récupération des données : scannage du fichier ...
%
while ~feof(fid); % lecture du fichier en entier
    %
    % ######################################################
    % # 1. lecture d'une ligne complète du fichier formaté #
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
    if strncmp(ligne,'Objet:',6) ; % ---> il y a un objet à traiter :
        %
        % Identification de l'objet à traiter
        %
        type_objet = sscanf(strrep(ligne,'Objet:',''),'%s',1) ;
        %
        % Recherche de l'indice numérique associé à cet objet
        %
        t = find(strcmp(M_clefs,type_objet)==1) ;
        %
        % Récupération des coordonnées suivant la prise de vue si l'objet est demandé
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
% sous fonction permettant la lecture des coordonnées d'un objet dans un fichier o3
% avec une prise en compte de lignes de commentaires ('#') pour certain point ...
%
% entrée : fid : file identifier du fichier traiter
%          Obj : structure à remplir avec les champs .tag et .coord
%
% sortie : Obj : structure remplie avec les champs .tag et .coord
%
%_______________________________________________________________________________________
%
% Récupération de l'indice de remplissage de la structure
%
init = size(Obj.tag,1) + 1 ;
%
% Initialisation de la variable de recherche ce Grid ou Lin
%
lecture = 'No' ;
%
% lecture de la ligne contenant les première informations 1er tag et 1eres coordonnées
%
ligne = fgetl(fid) ;
%
% récupération des données ...
%
while 1
    %
    % Récupération des informations si il le faut
    %
    if strcmp(lecture,'OK')
        %
        % récupération de la ligne
        %
        tag_temp = sscanf(ligne,'%s',1) ;            % récupération du tag temporaire
        tag_temp_ou = findstr(ligne,tag_temp) ;      % localisation du tag temporaire
        if isempty(tag_temp_ou) ;
            break
        end
        % on retire le tag de la ligne
        ligne = ligne(tag_temp_ou(1)+length(tag_temp):end) ;      
        [coor_temp,combien] = sscanf(ligne,'%f',3) ; % récupération des coordonnées temporaires
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
        % ---> Il y a des données à traiter
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