function [] = pipeline_harmonised_IK(st_protocole,cur_sujet,mysituation_name,...
mycinfile_nom,myosim_Matlab_name,rep_global,tolerance_contrainte_ik,plugin_STJ,rep_toolbox)

output_rep_cine = fullfile(rep_global,cur_sujet,mysituation_name);
rep_trc= fullfile(rep_global,cur_sujet,mysituation_name);

mycinfile_path = fullfile(rep_trc,mycinfile_nom) ;
data_trc = lire_donnees_trc(mycinfile_path) ; 

noms_poids=fieldnames(st_protocole.POIDS);
nb_poids=length(noms_poids);
nb_marqueurs=length(data_trc.noms);

if nb_poids<nb_marqueurs,
    disp('NB MARKERS TRC > nb markers model')
elseif nb_poids>nb_marqueurs,
    disp('NB MARKERS MODEL > nb markers trc')
end

poids=zeros(nb_poids,1);
for k=1:nb_poids
    hpoids=(strcat('(st_protocole.POIDS.',noms_poids{k}));
    hpoids=(strcat(hpoids,'{2})'));
    hpoids=eval(hpoids);
    hpoids=str2double(hpoids);
    poids(k,1)=hpoids;
end

modelfileOS =myosim_Matlab_name;
markerfileOS = mycinfile_nom ;
% outputfileOS = [mycinfile_nom(1:end-4) '_ik.mot'] ;
IKtaskfileOS = [mycinfile_nom(1:end-4) '_ik_task.xml'] ;
InputdirOS = rep_trc ;

file_sortie_ik_task=fullfile(output_rep_cine,IKtaskfileOS);
crea_xml_task_from_protOS_new(st_protocole,file_sortie_ik_task,'ik') ;

% xxxxxxxxxxxxxxxxxx
%   Ecriture du fichier xml
setup_InverseKinematics(...
    'ModelFile', modelfileOS, ...
    'MarkerFile', markerfileOS, ...
    'IKTasksFile', IKtaskfileOS, ...
    'InitialTime', [num2str(data_trc.tps(1)), ' '] ,...
    'FinalTime', num2str(data_trc.tps(end)) ,...
    'ResultsDirectory', output_rep_cine, ...
    'InputDirectory', InputdirOS,...
    'ConstraintWeight', tolerance_contrainte_ik);

% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           run the ik tool from the command line
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
com = ['ik -S ' fullfile(output_rep_cine, [mycinfile_nom(1:end-4) '_Setup_IK.xml']) ' -L ' plugin_STJ] ;

if isempty(strfind(st_protocole.PARAMETRES_OPENSIM.plugin_STJ{1,1},'32bit'))    
    chemin_monitor= fullfile(rep_toolbox,'Monitor.exe');  % ne fonctionne qu'en 64bit
    dos([chemin_monitor ' ' com])
elseif ~isempty(strfind(st_protocole.PARAMETRES_OPENSIM.plugin_STJ{1,1},'32bit'))
    dos(com)
end

file_sto=fullfile(rep_trc,'ik_model_marker_locations.sto');
new_file_sto=fullfile(rep_trc,[mycinfile_nom(1:end-4) '_ik.sto']);
if exist(file_sto,'file')
    movefile(file_sto,new_file_sto);%pareil?
% ECRITURE DU FICHIER DE RMSE
ecriture_erreur_rmse(mycinfile_path,new_file_sto);
end
end