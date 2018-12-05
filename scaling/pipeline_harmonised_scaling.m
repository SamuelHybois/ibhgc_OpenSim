function file_model_final = pipeline_harmonised_scaling(rep_global,path_cur_static,st_protocol,...
    cur_sujet,  rep_model_final,path_model_gen,mymass,plugin_STJ,choix)

[~,file_source_trc,~] = fileparts(path_cur_static);
rep_geometry = fullfile(rep_model_final,'Geometry');

file_model_final = pipeline_harmonised_creation_scaling_from_files( path_cur_static,st_protocol,...
                    cur_sujet,rep_model_final,path_model_gen, mymass,choix);

if ~exist(rep_geometry,'dir') % on copie les fichiers seulement s'il n'y sont pas.
    copyfile( fullfile(rep_global,'info_global','Geometry'), rep_geometry ) ;
    disp('copie des fichiers géométrie') ;
elseif isempty(find(cellfun(@isempty,strfind( cellstr(ls(rep_geometry)) , '.vtp' ) )==0, 1))
    copyfile( fullfile(rep_global,'info_global','Geometry'), rep_geometry ) ;
    disp('copie des fichiers géométrie') ;
end
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           batch opensim de génération du modèle à partir des fichiers déclarés
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% com = ['C:\OpenSim_3.3\bin\scale.exe -S ' char(fullfile(rep_model_final,[file_source_trc '_' choix '_setup.xml'])) ' -L ' plugin_STJ];
com = ['scale.exe -S ' char(fullfile(rep_model_final,[file_source_trc '_' choix '_setup.xml'])) ' -L ' plugin_STJ];
system(com);

end