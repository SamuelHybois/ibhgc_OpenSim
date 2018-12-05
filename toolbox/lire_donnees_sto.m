function [segment_pos,segment_ddl,st_segment_pos]=lire_donnees_sto(fichier_sto)
% Function qui permet d'extraire les donn�es cin�matiques des fichier .STO,
% c�d la cin�matique segmentaire dans le rep�re global.
%
% INPUT  
% fichier_STO : string chemin d'acc�s + nom du fichier de donn�es
%
% OUTPUTS
% segment_pos : matrice de N positions par M degr�s de libert� (ddl)
% segment_ddl : tableau de N cellules comprenant les noms de chaque ddl
% st_segment_pos : les deux pr�c�dent sous forme de structure

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
    % (la ligne pr�cedente commence par 'time')
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
 
 % �criture en format structure
for iddl=2:length(segment_ddl)
    st_segment_pos.(char(segment_ddl(iddl))) = segment_pos(:,iddl);
end
end