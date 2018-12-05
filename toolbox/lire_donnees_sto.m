function [segment_pos,segment_ddl,st_segment_pos]=lire_donnees_sto(fichier_sto)
% Function qui permet d'extraire les données cinématiques des fichier .STO,
% càd la cinématique segmentaire dans le repère global.
%
% INPUT  
% fichier_STO : string chemin d'accès + nom du fichier de données
%
% OUTPUTS
% segment_pos : matrice de N positions par M degrés de liberté (ddl)
% segment_ddl : tableau de N cellules comprenant les noms de chaque ddl
% st_segment_pos : les deux précédent sous forme de structure

%% ************* ouverture fichier
fid=fopen(fichier_sto,'r');
if isempty(fichier_sto) || fid==-1
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
    segment_ddl = strread(ligne,'%s'); 
    
    % donnees segmentaires 
    segment_pos = dlmread(fichier_sto,'\t',nbligne,0); 
    segment_pos(find(segment_pos==0)) = NaN;       
end
 fclose(fid);
 
 % écriture en format structure
for iddl=2:length(segment_ddl)
    st_segment_pos.(char(segment_ddl(iddl))) = segment_pos(:,iddl);
end
end