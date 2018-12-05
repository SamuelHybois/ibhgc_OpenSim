<<<<<<< HEAD
%% 2eme version : trc+mot sans cropper

rep_global='\\10.134.8.200\csrt\viconC3D\TdT_B';
rep_sortie='E:\These_Thibault_Marsan\BDD_Tennis_de_Table\1_Structure_Data\BDD_pretraitee';
rep_info_global='E:\These_Thibault_Marsan\BDD_Tennis_de_Table\info_global';
[~,fichier_prot]=PathContent_Type(rep_info_global,'.protOS');
st_protocole_pretraitement=lire_fichier_prot_2(fullfile(rep_info_global,fichier_prot{1}));
=======
%% 1ere version : juste transformer le c3d en trc

rep_global='C:\Users\visiteur\Desktop\Cd_stat';

>>>>>>> dev_diane_ENSAM
list_sujet=dir(rep_global);
M_pass_VICON_OS=[[0 -1 0]',[0 0 1]',[-1 0 0]'];
for i_sujet=1:size(list_sujet,1)
    cur_sujet=list_sujet(i_sujet).name;
    if ~isempty(strfind(cur_sujet,'TdT'))
        list_activity=dir(fullfile(rep_global,cur_sujet));
        for i_activity=1:size(list_activity,1)
            cur_activity=list_activity(i_activity).name;
<<<<<<< HEAD
            if ~isempty(strfind(cur_activity,'Coup')) || ...
                    ~isempty(strfind(cur_activity,'Revers')) ||...
                    ~isempty(strfind(cur_activity,'Pivot'))
=======
            if strcmpi(cur_activity,'coupdroit') || ...
                    strcmpi(cur_activity,'revers') ||...
                    strcmpi(cur_activity,'pivot')
>>>>>>> dev_diane_ENSAM
                list_c3d=dir(fullfile(rep_global,cur_sujet,cur_activity));
                for i_c3d=1:size(list_c3d,1)
                    nom_c3d=list_c3d(i_c3d).name;
                    if ~isempty(strfind(nom_c3d,'.c3d'))
                        c3d_file=fullfile(rep_global,cur_sujet,cur_activity,nom_c3d);
<<<<<<< HEAD
                        dossier_sortie=fullfile(rep_sortie,cur_sujet,cur_activity);
                        disp(['Création du fichier trc pour ',nom_c3d(1:end-4),' de ',cur_sujet])
                        c3d2trc_crop_chgt_repere_V2(c3d_file,M_pass_VICON_OS,dossier_sortie);
                        %% écriture du fichier mot des efforts
                        data_c3d=btk_loadc3d(c3d_file);
                        nb_frame=data_c3d.marker_data.Info.NumFrames;
                        frequence_vicon=data_c3d.marker_data.Info.frequency;
                        cur_temps_debut=0;
                        cur_temps_fin=nb_frame/frequence_vicon;
                        nom_fichier_mot_effort=nom_c3d(1:end-4);
                        dossier_sortie=fullfile(rep_sortie,cur_sujet,cur_activity);
                        % Passage du repère VICON vers OpenSim et création du fichier mot
                        disp(['Création du fichier mot pour ',nom_c3d(1:end-4),' de ',cur_sujet])
                        [~]=harmonised_ecriture_mot_effort_TdT(data_c3d, nom_fichier_mot_effort,c3d_file,M_pass_VICON_OS, dossier_sortie, cur_temps_debut, cur_temps_fin,st_protocole_pretraitement);
                        
=======
                        c3d2trc_crop_chgt_repere(c3d_file,M_pass_VICON_OS);
>>>>>>> dev_diane_ENSAM
                    end
                end
            elseif strcmpi(cur_activity,'statique')
                path_c3d=fullfile(rep_global,cur_sujet,cur_activity,'\*c3d');
                my_acquisitions=dir(path_c3d);
                c3d2trc_crop_chgt_repere(fullfile(rep_global,cur_sujet,cur_activity,my_acquisitions(1).name),M_pass_VICON_OS)
            end
        end
    end
end