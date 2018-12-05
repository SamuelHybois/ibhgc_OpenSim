function pipeline_pretraitement_golfV2%( nom_sujet, fichier_protocole, chemin_excel_labelisation, dossier_base_de_donnee,dossier_sortie )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


%% Fichiers
% dossier_base_de_donnee='C:\Users\visiteur\Desktop\rep_global_foot\brut';
% dossier_base_de_donnee='C:\Users\visiteur\Desktop\rep_global_traitement_video';
dossier_base_de_donnee='C:\Users\visiteur\Desktop\gym_conversion_c3d_stat';
dossier_sortie=dossier_base_de_donnee;
% dossier_sortie='C:\Users\visiteur\Desktop\rep_global_traitement_video';
M_pass_VICON_OS=[[0 -1 0]',[0 0 1]',[-1 0 0]'];
fichier_protocole=fullfile(dossier_base_de_donnee,'info_global','juin_2017_IBHGC_fullbodyV4_golf');
reserved_dir_without_info_global = {'.','..','.DS_Store','info_global','Info_global','Info_Global','modele'} ; % pour enlever les dossiers fantômes .,..,DS_store (mac)

sujets=dir(dossier_base_de_donnee);

for i_sujet=1:size(sujets,1)
    if isempty( find(strcmp(sujets(i_sujet).name,reserved_dir_without_info_global), 1))
        cur_sujet=sujets(i_sujet).name;
        cur_num=NaN;
%         [st_sujet]=tous_les_chemins_sujet(cur_sujet,dossier_base_de_donnee);
        for i=1:length(sujets)
            if ~isempty(strfind(cur_sujet,sujets(i).name))
                cur_num=i;
            end
        end
        
        
        cur_dossier_sujet=sujets(cur_num).name;
        repertoire_activite=fullfile(dossier_base_de_donnee,cur_dossier_sujet);
        my_activities=dir(repertoire_activite);
%         chemin_excel_labelisation=fullfile(dossier_base_de_donnee,cur_dossier_sujet,[cur_dossier_sujet,'_labellisation.xlsx']);
%         [~,~,excel_labellisation]=xlsread(chemin_excel_labelisation);
%         nb_ligne=size(excel_labellisation,1);
        for i_activity = 1:length(my_activities)
            if isempty( find(strcmp(my_activities(i_activity).name,reserved_dir_without_info_global), 1))
                cur_activity=my_activities(i_activity).name;
                if strcmp(cur_activity,'statique')||strcmp(cur_activity,'Statique')
                    mkdir(fullfile(dossier_sortie,'modele'))
%                     [~,cur_statique,ext_cur_statique]=fileparts(st_sujet.chemin_statique_valide);
                    cur_statique='statique_02';
                    ext_cur_statique='.c3d';
                    copyfile(fullfile(dossier_base_de_donnee,cur_dossier_sujet,cur_activity,[cur_statique,ext_cur_statique]),...
                        fullfile(dossier_sortie,'modele',[cur_statique,ext_cur_statique]))
                    c3d2trc_crop_chgt_repere(fullfile(dossier_sortie,cur_sujet,'modele',[cur_statique,ext_cur_statique]),M_pass_VICON_OS)
                else
                    cur_dossier_c3d=fullfile(repertoire_activite,cur_activity);
                    path_c3d=fullfile(cur_dossier_c3d,'\*c3d');
                    my_acquisitions=dir(path_c3d);
                    
                    for i_acquisition=1:length(my_acquisitions)
                        cur_acquisition=my_acquisitions(i_acquisition).name;
                        cur_chemin_c3d=fullfile(cur_dossier_c3d,cur_acquisition);
                        nom_c3d=cur_acquisition(1:end-4);
                        for i_ligne=1:nb_ligne
                            cur_ligne=excel_labellisation{i_ligne,1};
                            if strcmp(cur_ligne,nom_c3d)
                                ligne_acq=i_ligne;
                            end
                        end
                        %                 try
                        %                     chemin_excel_labelisation=chemin_excel_labelisation_tous{i_sujet};
                        %                     [ cur_validite] = lecture_excel_simple_valeur( chemin_excel_labelisation, 'c.complet', nom_c3d );
                        %                 catch
                        %                     cur_validite=0;
                        %                 end
                        %                 if strcmp(cur_validite,'ok')==1 || strcmp(cur_validite,'Ok')==1 || strcmp(cur_validite,'oK')==1
%                         cur_validite=excel_labellisation(ligne_acq,2);
                        cur_validite='ok';
                        if strcmpi(cur_validite,'ok')
                            dossier_sortie_suj=fullfile(dossier_sortie,cur_sujet);
                            pre_traitement_golfV2(cur_chemin_c3d,excel_labellisation,dossier_sortie_suj,cur_sujet,fichier_protocole,M_pass_VICON_OS);
                        end
                    end
                end
            end
        end
    end
end
end


