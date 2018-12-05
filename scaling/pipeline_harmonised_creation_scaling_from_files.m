function [nom_model_final] = pipeline_harmonised_creation_scaling_from_files( statref_trc_file,...
    st_protocole, nom_patient, rep_sortie_model , modele_gen_path,mymass,choix)


data_static_trc = lire_donnees_trc(statref_trc_file);
temps_inf = data_static_trc.tps(1);
temps_sup = data_static_trc.tps(end);

nom_scaling_tool = strcat(nom_patient,'_scaled');

% noms des fichiers écrits en sortie
nom_model_final = [nom_patient  '_model_' choix '_final.osim'];      % fichier du modèle final
nom_model_step1 = [nom_patient  '_model_' choix '_step1.osim'];    % fichier du modèle mis à l'échelle mais non recalé sur les marqueurs
nom_sortie_marqueurs_new = [nom_patient '_marqueurs_new_output.osim'] ; % nouvelles positions des marqueurs
[~, fname_tmp, ~] = fileparts(statref_trc_file);
nom_fichier_scaling = [fname_tmp '_' choix '_setup.xml'] ;  % fichier xml de définition de la fonction scale
nom_fichier_motion = [nom_patient  '_' choix '_motion.mot'] ; %   fichier de mouvement

% if strcmp(choix,'scale_2')
%     nom_fichier_coordinates = [nom_patient '_scale1_motion.mot'];
% else
    nom_fichier_coordinates = 'Unassigned';
% end

nom_fichier_scale_output = [nom_patient,  '_' choix '_output.xml'] ;
file_fichier_scaling = fullfile(rep_sortie_model, nom_fichier_scaling) ;

% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
[rep_model,nom_model_gen,ext_model_gen]=fileparts(modele_gen_path);
nom_model_gen=[nom_model_gen ext_model_gen];
modelfileOS = fullfile(chemin_relatif_OS(rep_sortie_model,rep_model),nom_model_gen) ;

[chemin_statref_trc,nom_statref_trc,ext_statref_trc]=fileparts(statref_trc_file);
nom_statref_trc=[nom_statref_trc ext_statref_trc];
markerfileOS = fullfile(chemin_relatif_OS(rep_sortie_model,chemin_statref_trc),nom_statref_trc) ;

%récupération des données de poids
noms_poids=fieldnames(st_protocole.POIDS);
nb_poids=length(noms_poids);

poids=zeros(nb_poids,1);
for k=1:nb_poids
    hpoids=(strcat('(st_protocole.POIDS.',noms_poids{k}));
    hpoids=(strcat(hpoids,'{1})'));
    hpoids=eval(hpoids);
    hpoids=str2double(hpoids);
    poids(k,1)=hpoids;
end

    file_sortie_scale_measureset = fullfile( rep_sortie_model, [choix '_measure_set.xml']) ;
    file_sortie_scale_task = fullfile( rep_sortie_model, [choix '_task.xml']) ;
    
    crea_xml_scalemesset_from_protOS( st_protocole, file_sortie_scale_measureset) ;
    crea_xml_task_from_protOS_new( st_protocole, file_sortie_scale_task, choix ) ;
    
    %max mark move from model
%     if strcmp(choix,'scaling_1'), 
%           max_mark_mov = 0;%zero
%     else 
            max_mark_mov = -1;%infini
%     end
    
    
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           Début de création du fichier XML
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% création du répertoire si non existant
mkdir( rep_sortie_model ) ;

% début d'écriture
fid=fopen( file_fichier_scaling, 'w' );

%% écriture de l'en-tête de scaling
fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8" ?>');
fprintf(fid,'%s\n','<OpenSimDocument Version="30000">');
fprintf(fid,'\t%s\n',['<ScaleTool name="',nom_scaling_tool,'">']);
fprintf(fid,'\t\t%s','<mass>');
fprintf(fid, '%d', mymass);
fprintf(fid, '%s\n', '</mass>');
fprintf(fid,'\t\t%s\n','<height>-1</height>');
fprintf(fid,'\t\t%s\n','<age>-1</age>');
fprintf(fid,'\t\t%s\n','<notes>Unassigned</notes>');
fprintf(fid,'\t\t%s\n','<GenericModelMaker>');
fprintf(fid,'\t\t\t%s\n',['<model_file>', modelfileOS, '</model_file>']);     
fprintf(fid,'\t\t\t%s\n','<marker_set_file>Unassigned</marker_set_file>');
fprintf(fid,'\t\t%s\n','</GenericModelMaker>');
fprintf(fid,'\t\t%s\n','<ModelScaler>');
fprintf(fid,'\t\t\t%s\n','<apply>true</apply>');
fprintf(fid,'\t\t\t%s\n','<scaling_order> measurements</scaling_order>');

% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%       creation scale measurement set
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fprintf(fid,'%s\n', ['<MeasurementSet file="' choix '_measure_set.xml"/>']); 


% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fprintf(fid,'\t\t\t%s\n','<ScaleSet>');
fprintf(fid,'\t\t\t\t%s\n','<objects />');
fprintf(fid,'\t\t\t\t%s\n','<groups />');
fprintf(fid,'\t\t\t%s\n','</ScaleSet>');
fprintf(fid,'\t\t\t%s\n',['<marker_file>', markerfileOS,'</marker_file>']);   
fprintf(fid,'\t\t\t%s\n',['<time_range> ', num2str(temps_inf), ' ', num2str(temps_sup),  ' </time_range>']);  
fprintf(fid,'\t\t\t%s\n',...
    '<preserve_mass_distribution>true</preserve_mass_distribution>');  
fprintf(fid,'\t\t\t%s\n',...
    ['<output_model_file>', nom_model_step1, '</output_model_file>']);
fprintf(fid,'\t\t\t%s\n',['<output_scale_file>', nom_fichier_scale_output, '</output_scale_file>']);
fprintf(fid,'\t\t%s\n','</ModelScaler>');
fprintf(fid,'\t\t%s\n','<MarkerPlacer>');
fprintf(fid,'\t\t\t%s\n','<apply>true</apply>');

% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%       creation IK taskset
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fprintf(fid,'%s\n',['<IKTaskSet file="' choix '_task.xml"/>']);  

fprintf(fid,'\t\t\t%s\n',['<marker_file>', markerfileOS, '</marker_file>']);  
% fprintf(fid,'\t\t\t%s\n',['<coordinate_file>' nom_fichier_coordinates '</coordinate_file>']);
fprintf(fid,'\t\t\t%s\n',['<time_range> ', num2str(temps_inf), ' ', num2str(temps_sup),  ' </time_range>']);    
fprintf(fid,'\t\t\t%s\n',['<output_motion_file>', nom_fichier_motion, '</output_motion_file>']); 
fprintf(fid,'\t\t\t%s\n',['<output_model_file>', nom_model_final, '</output_model_file>']); 
fprintf(fid,'\t\t\t%s\n',['<output_marker_file>', nom_sortie_marqueurs_new, '</output_marker_file>']); 
fprintf(fid,'\t\t\t%s\n',sprintf('<max_marker_movement> %g </max_marker_movement>',max_mark_mov)); 
fprintf(fid,'\t\t%s\n','</MarkerPlacer>');
fprintf(fid,'\t%s\n','</ScaleTool>');
fprintf(fid,'%s\n','</OpenSimDocument>');

fclose(fid);

disp([fname_tmp '_' choix '_setup.xml has been created'])

end

