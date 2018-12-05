rep_global='C:\Users\2016-1416.ENSAM\Desktop\DATA_pretaitee';

reserved_dir_without_info_global = {'.','..','.DS_Store','info_global','Info_global','Info_Global','modele'} ; % pour enlever les dossiers fantômes .,..,DS_store (mac)

my_sujets=dir(rep_global);

arg_plot.sequence=1;
arg_plot.Crunch_factor=1;
arg_plot.X_factor=1;
arg_plot.vitesses_segments=0;
arg_plot.Puissances=1;
arg_plot.plan_swing=0;

for i_sujet = 1:length(my_sujets)
    if isempty(find(strcmp(my_sujets(i_sujet).name,reserved_dir_without_info_global),1)) && my_sujets(i_sujet).isdir
        cur_sujet=my_sujets(i_sujet).name;
        disp(['************************ Traitement de ',cur_sujet,' ************************'])
        rep_osim_scaled=fullfile(rep_global,cur_sujet,'modele',[cur_sujet,'_model_final_unconstrained.osim']);
        tree=xml_readOSIM(rep_osim_scaled);
        [~,nom_osim,~]=fileparts(rep_osim_scaled);
       
        %% Boucle activités
        repertoire_activites = fullfile(rep_global,cur_sujet);
        my_activities= dir(repertoire_activites);
        file_xls=fullfile(repertoire_activites,[cur_sujet,'_labellisation.xlsx']);
        for i_activity = 1:length(my_activities)
            if isempty( find(strcmp(my_activities(i_activity).name,reserved_dir_without_info_global),1)) && my_activities(i_activity).isdir
                cur_activity=char(my_activities(i_activity).name);
                disp(['    Activité ',cur_activity])
                % Récupération de tous les fichiers trc de l'activité
                [~,my_acquisitions] = PathContent_Type(fullfile(repertoire_activites,cur_activity),'.trc');
                
                for i_acquisition=1:length(my_acquisitions)
                    cur_acquisition=char(my_acquisitions(i_acquisition));
                    if isempty(strfind(cur_acquisition,'ik_virt'))
                        rep_analyze=[cur_acquisition(1:end-4),'_ANALYZE'];
                        file_pos=[nom_osim,'_BodyKinematics_pos_global.sto'];
                        path_pos=fullfile(rep_global,cur_sujet,cur_activity,rep_analyze,file_pos);
                        file_vit=[nom_osim,'_BodyKinematics_vel_global.sto'];
                        path_vit=fullfile(rep_global,cur_sujet,cur_activity,rep_analyze,file_vit);
                        path_ID=fullfile(rep_global,cur_sujet,cur_activity,[cur_acquisition(1:end-4),'_id.sto']);
                        acq_split=strsplit(cur_acquisition(1:end-4),'_');
                        C=strsplit(cur_acquisition(1:end-4),'_');
                        nom_c3d=strjoin(C(4:end),'_');
                        file_c3d=fullfile(rep_global,cur_sujet,cur_activity,[nom_c3d,'.c3d']);
                        dossier_sortie=fullfile(rep_global,cur_sujet,cur_activity,['Resultats_',cur_activity,'_',cur_sujet]);
                        if ~exist(dossier_sortie,'dir')
                            mkdir(fullfile(dossier_sortie))
                        end
%                         try
                            disp(['        Acquisition ',cur_acquisition])
                            post_traitement(tree,path_pos,path_vit,path_ID,file_xls,file_c3d,arg_plot,dossier_sortie,cur_acquisition,cur_sujet)
%                         catch
%                             disp(['     !!! Erreur de post-traitement pour ',cur_acquisition])
%                         end
                    end
                end % for i_acquisition
            end % if isempty
        end % for i_activity
    end % if isempty
end % for i_sujet

