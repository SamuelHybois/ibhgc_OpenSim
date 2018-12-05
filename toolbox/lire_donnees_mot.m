function [joint_pos,joint_ddl,st_joint_pos]=lire_donnees_mot(fichier_mot,radians)
% Ouverture des fichiers de coordonnées généralisées issu d'OpenSim
%
% INPUT
% fichier_mot : chemin +nom du fichier à lire
%
% OUTPUTS
% joint_pos : matrice de N positions par M degrés de liberté (ddl)
% joint_ddl : tableau de N cellules comprenant les noms de chaque ddl
% st_joint_pos : les deux précédent sous forme de structure 


%% ************* ouverture fichier
fid=fopen(fichier_mot,'r');
if isempty(fichier_mot) || fid==-1
    FICH.noms=0;
    FICH.coord=0;
    disp('le fichier n''existe pas')
else
    ligne=fgetl(fid);
    nbligne =1;
    % detection de la 1ere ligne contenant les coordonnees
    % (la ligne précedente commence par 'time')
    while isempty(strfind(ligne,'time'))
        ligne=fgetl(fid);
        nbligne = nbligne +1 ;
    end
    
    % nom des degres de liberte
    joint_ddl = strread(ligne,'%s'); 
    
    % donnees articulaires 
    joint_pos = dlmread(fichier_mot,'\t',nbligne,0); 
    joint_pos(find(joint_pos==0)) = NaN;
   
    if nargin>=2, change=pi/180;
    else change=1;
    end
    
    for iddl=1:length(joint_ddl)
        if iddl~=4 && iddl~=5 && iddl~=6
           joint_pos(:,iddl) = joint_pos(:,iddl)*change;   
        end
   % écriture en format structure
        if iddl>=2
            st_joint_pos.(char(joint_ddl(iddl))) = joint_pos(:,iddl);
        end
    end
    
end
 fclose(fid); 

end