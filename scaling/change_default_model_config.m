function    file_model_out = change_default_model_config(file_motion,path_model_in)
% This function aims at changing default body joint configurations to a
% given static pose in a mot file from OpenSim IK

%0) INITIALIZE
%0.1) Definir les path d'entree et de sortie des modeles
[rep_model,file_model] = fileparts(path_model_in);
file_model_out = [file_model(1:end-5) 'static.osim'];
path_model_out = [rep_model filesep file_model_out]; 

%0.2) Charger les coordonnées articulaires
[joint_pos,joint_ddl,st_joint_pos] = lire_donnees_mot(file_motion);

%0.3) Récupérer le texte du fichier de modele
fid = fopen(char(path_model_in));
text = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
fclose(fid);
nbline = numel(text{1,1});

%1) CHANGE DEFAULT COORDINATES
%1.1) Recupérer la liste des coordonnees articulaires du modele
for iline = 1:nbline
    line = text{1,1}(iline,1);    
    if ~cellfun(@isempty,strfind(line,'<Coordinate name='))
        lim = strfind(line{1,1},'"');
        num_coord = strcmp(joint_ddl, cellstr(line{1,1}(lim(1)+1:lim(2)-1)) );
        old_coord_text = text{1,1}(iline+4,1);
        old_coord = str2num(old_coord_text{1}(16:end-16));
        new_coord = old_coord+joint_pos(num_coord==1);
        text{1,1}(iline+4,1)= cellstr(sprintf('<default_value>%f</default_value>',new_coord));
    end
end

%%2) WRITE NEW MODEL: Reecrire le fichier texte du modelde opensim
fid = fopen(char(path_model_out), 'w');
for iline = 1:nbline
    fprintf(fid, '%s\n', char(text{1,1}{iline}));
end
fclose(fid);




end