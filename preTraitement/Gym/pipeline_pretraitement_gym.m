%% Programme pour créer le .trc et le grf.mot à partir des c3d
rep_global = uigetdir('Z:/','Choisir le rep_global');
info_global = fullfile(rep_global,'info_global');
[~,nom_prot] = PathContent_Type(info_global,'.protOS');
myprot_path = fullfile(info_global,nom_prot{1});
st_protocole=lire_fichier_prot_2(myprot_path);
list_sujet=dir(rep_global);
M_pass_VICON_OS=[[0 -1 0]',[0 0 1]',[-1 0 0]'];

for i_sujet=1:size(list_sujet,1)
    cur_sujet=list_sujet(i_sujet).name;
    if contains(cur_sujet,{'gym','Gym'})
        list_activity=dir(fullfile(rep_global,cur_sujet));
        for i_activity=1:size(list_activity,1)
            cur_activity=list_activity(i_activity).name;
            if strcmpi(cur_activity,'MouvGR') || ...
                    strcmpi(cur_activity,'MvtsFonctionnels')|| ...
                    strcmpi(cur_activity,'Mouv_fcts')|| ...
                    strcmpi(cur_activity,'Mouv_gym')
                list_c3d=dir(fullfile(rep_global,cur_sujet,cur_activity));
                for i_c3d=1:size(list_c3d,1)
                    nom_c3d=list_c3d(i_c3d).name;
                    if contains(nom_c3d,'.c3d')
                        % Création du .trc
                        c3d_file=fullfile(rep_global,cur_sujet,cur_activity,nom_c3d);
                        c3d2trc_crop_chgt_repere_gym(c3d_file,M_pass_VICON_OS);
                        % Creer le GRF.mot pour la dynamique inverse
                        dossier_sortie=fullfile(rep_global,cur_sujet,cur_activity);
                        data_c3d=btk_loadc3d(c3d_file);
                        [~, nom_c3d_mot, ~]=fileparts(c3d_file);
                        frequence_vicon=data_c3d.marker_data.Info.frequency;
                        cur_frame_vicon_debut=data_c3d.marker_data.First_Frame;
                        cur_frame_vicon_fin=data_c3d.marker_data.Last_Frame;
                        cur_temps_debut=cur_frame_vicon_debut/frequence_vicon;
                        cur_temps_fin=cur_frame_vicon_fin/frequence_vicon;
                        nom_fichier_mot_effort=[nom_c3d_mot '_grf'];
                        disp(['Création du fichier mot pour ',nom_c3d_mot])
                        cell_marqueurs={'MT1D','MT5D','CALD';'MT1G','MT5G','CALG';'MC2D','MC5D','PSRD';'MC2G','MC5G','PSRG'};
                        [~]=ecriture_mot_gym(c3d_file, nom_fichier_mot_effort,M_pass_VICON_OS, dossier_sortie, cur_temps_debut, cur_temps_fin,st_protocole,cell_marqueurs);
%                         [~]=harmonised_ecriture_mot_effortV3(data_c3d, nom_fichier_mot_effort,c3d_file,M_pass_VICON_OS, dossier_sortie, cur_temps_debut, cur_temps_fin,st_protocole);
                    end
                end
            elseif strcmpi(cur_activity,'statique') || strcmpi(cur_activity,'modele')
                path_c3d=fullfile(rep_global,cur_sujet,cur_activity,'\*c3d');
                my_acquisitions=dir(path_c3d);
                c3d2trc_crop_chgt_repere_gym(fullfile(rep_global,cur_sujet,cur_activity,my_acquisitions(1).name),M_pass_VICON_OS)
            end
        end
    end
end