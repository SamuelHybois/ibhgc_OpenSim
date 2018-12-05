clear, clc, %close all

%% Paramètres specifiques au script
% Entree
size_interp=101;
% Sortie
ERR_CL=[]; ERR_OS=[];
mean_ERR_CL=[]; mean_ERR_OS=[];
log_error={};

%% Récupération des données du dossier info_global
rep_global = uigetdir('Z:/','Choisir le rep_global');
info_global = fullfile(rep_global,'info_global') ;

%Recuperation du monitor dans la toolbox
rep_toolbox = fileparts(which('mainPipeline.m'));
addpath(genpath(rep_toolbox)) 

% Fichier Excel infos sujets
[~,nom_excel_info_sujets] = PathContent_Type(info_global,'.xlsx');
structure_excel=excel2structure(fullfile(info_global,nom_excel_info_sujets{1}));

% Modèle générique OpenSim
[~,nom_modele_osim] = PathContent_Type(info_global,'.osim');
[~,nom_modele_mat] = PathContent_Type(info_global,'.mat');
if 1%isempty(nom_modele_mat)
    Struct_OSIM_gen = xml_readOSIM_TJ(fullfile(info_global,nom_modele_osim{1}),struct('Sequence',true));
    save(char(fullfile(info_global,[nom_modele_osim{1}(1:end-5) '.mat'])),'Struct_OSIM_gen');
else
    load(fullfile(info_global,nom_modele_mat{1}))
end

% Fichier .prot
[~,nom_prot] = PathContent_Type(info_global,'.protOS');
myprot_path = fullfile(info_global,nom_prot{1});
st_protocole=lire_fichier_prot_2(myprot_path);

% Paramètres par défaut pour l'IK et l'ID
tolerance_contrainte_ik = str2double(st_protocole.PARAMETRES_OPENSIM.tolerance_contrainte_ik{1}) ;
f_filtre_ID = str2double(st_protocole.PARAMETRES_OPENSIM.freq_filtre_id{1}) ;
plugin_STJ = st_protocole.PARAMETRES_OPENSIM.plugin_STJ{1} ;
type_filtre = st_protocole.PARAMETRES_OPENSIM.type_filtre_ik ; % 'MG' (moyenne glissante) ou 'BW' (Butterworth)

%% Boucle activités
% [my_activities,~] = PathContent(repertoire_activites);
my_activities = {'Prop_ScapLoc','Basket_ScapLoc','Tennis_ScapLoc'};
nb_activity=length(my_activities);
for i_activity = 3%1:nb_activity
%     if isempty( find(strcmp(my_activities(i_activity),reserved_dir_without_info_global),1))
cur_activity=char(my_activities(i_activity));
log_error{end+1}=cur_activity;
if strfind(cur_activity,'Prop'), phases = {'Push','Recovery'};
elseif strfind(cur_activity,'Basket'), phases = {'Arm','Throw'};
elseif strfind(cur_activity,'Tennis'), phases = {'Arm','Throw','Follow'};
end, nb_phase = length(phases);

    %% Boucle Sujets
    reserved_dir_without_info_global = {'.','..','.DS_Store','info_global','Info_global','Info_Global','modele','fichiers_wrl','Statique','MvtsFonctionnels'} ; % pour enlever les dossiers fantômes .,..,DS_store (mac)
    sujets=fieldnames(st_protocole.SUJETS);
    if strcmp(sujets{1},'all')
        [my_sujets,~] = PathContent(rep_global);
        true_subjects(length(my_sujets),1)=0;
        for i=1:length(reserved_dir_without_info_global), true_subjects=strcmp(my_sujets,reserved_dir_without_info_global(i))+true_subjects; end
        true_subjects= find(sum(true_subjects,2)==0);
    else
        my_sujets=sujets;
        true_subjects=1:length(sujets);
    end
    nb_subjects=length(true_subjects);

    for i_sujet = 1:nb_subjects

            cur_sujet = char(my_sujets(true_subjects(i_sujet)));
            cur_path = char(fullfile(rep_global,cur_sujet,cur_activity));
            log_error{end+1} = cur_sujet;
            rep_sortie_model = fullfile(rep_global,cur_sujet,'modele');
            
            % Define static file that will be used for all processing
            cur_static = define_static_file(cur_path,myprot_path,st_protocole);
            
            % PRE-TRAITEMENT: préparations des fichiers trc entiers
            if 0%isfield(st_protocole.FONCTION_A_LANCER,'PREPROCESSING')
                if strcmp(st_protocole.FONCTION_A_LANCER.PREPROCESSING{1},'1')
                    Pipeline_preprocessing(rep_global,cur_sujet,cur_activity,cur_static,nom_prot)
                end
            end

            %SCALING
            % Lecture de la masse du sujet courant
            % Manque calcul masse modèle (% de la masse ex: fauteuil) à mettre dans le prot
            try
                cur_mass = cur_sujet_mass(structure_excel,st_protocole,cur_sujet);
            catch
                cur_mass=NaN;
                log_error{end+1}='masse du sujet non renseignée';
            end

            if ~strcmp(st_protocole.FONCTION_A_LANCER.Scaling{1},'0')
                try
                    if isfield(st_protocole,'SCALING_MASSE')
                        cur_mass=(str2double(st_protocole.SCALING_MASSE.prop_mass_model{1})/100)*cur_mass; % Permet de prendre en compte que le modèle ne fait pas 100% du poids du sujet
                    end                    
%                     if ~strcmp(st_protocole.FONCTION_A_LANCER.Scaling{1},'1')
                        [myosim_Matlab_name,struct_OSIM] = pipeline_scaling(nom_modele_osim,rep_global,...
                            st_protocole,cur_sujet,cur_mass,cur_static,cur_activity,plugin_STJ);                        
%                     elseif ~strcmp(st_protocole.FONCTION_A_LANCER.Scaling{1},'2')
%                         [myosim_Matlab_name,struct_OSIM] = pipeline_scaling_sans_OS(nom_modele_osim,rep_global,...
%                             st_protocole,cur_sujet,cur_mass,plugin_STJ);
%                     else
%                         log_error{end+1}='V alue for scaling in .prot unknown';
%                     end
                catch
                    log_error{end+1}='scaling non effectué';
                end
            else
                load(fullfile(rep_global,cur_sujet,'modele',[cur_sujet '_model_final.mat']))
                myosim_Matlab_name = fullfile(rep_global,cur_sujet,'modele',[cur_sujet '_model_final.osim']);
            end

            %PERSONNALISATIONS
            if isfield(st_protocole.FONCTION_A_LANCER,'ANALYSE_MUSCLE_PERSO')
                if strcmp(st_protocole.FONCTION_A_LANCER.ANALYSE_MUSCLE_PERSO{1},'1') % Ajouter regarder si le fichier existe déjà.
                    Wraps= Extract_Wraps(rep_global,cur_sujet,struct_OSIM);
                end
            end

            if isfield(st_protocole.FONCTION_A_LANCER,'AJOUT_BODY_FAUTEUIL')
                if strcmp(st_protocole.FONCTION_A_LANCER.AJOUT_BODY_FAUTEUIL{1},'1')
                    [modelOS] = add_FRM_model_OS(rep_global,cur_sujet,myosim_Matlab_name);
                end
            end
            if isfield(st_protocole,'PERSONNALISATION')
                if isfield(st_protocole.PERSONNALISATION,'chaine_cinematique')
                    if strcmp(st_protocole.PERSONNALISATION.chaine_cinematique{1},'EOS')
                        disp(['Personnalisation EOS de ',cur_sujet])
                        chaine_a_evaluer=strcat('model_perso_EOS=',st_protocole.PERSONNALISATION.chaine_cinematique{2},'(rep_global,cur_sujet,struct_OSIM,st_protocole);');
                        eval(chaine_a_evaluer)
                        myosim_Matlab_name=fullfile(rep_global,cur_sujet,'modele',[cur_sujet,'_perso_EOS.osim']);
                        xml_writeOSIM_TJ(myosim_Matlab_name,model_perso_EOS,'OpenSimDocument');
                    end
                end
            end

            % Création du modèle sans contraintes pour ID et Analyze plus rapide
            myosim_Matlab_name_unconstrained = Unconstrain_Model(myosim_Matlab_name);

                %% Boucle acquisitions
                % Récupération de tous les fichiers trc de l'activité
                repertoire_sujet = fullfile(rep_global,cur_sujet);
                [~,my_acquisitions] = PathContent_Type(fullfile(repertoire_sujet,cur_activity),'.trc');
                nb_acquisition=length(my_acquisitions);
                
                for i_acquisition = 1:nb_acquisition
                cur_acquisition=char(my_acquisitions(i_acquisition)); 
                    
                    if isempty(strfind(cur_acquisition,'ik_virt'))
                        
                        %IK
                        if 1%strcmp(st_protocole.FONCTION_A_LANCER.IK{1},'1')
                            try
                                pipeline_harmonised_IK(st_protocole,cur_sujet,...
                                    cur_activity,cur_acquisition,myosim_Matlab_name,rep_global,...
                                    tolerance_contrainte_ik,plugin_STJ,rep_toolbox)
                                pipeline_harmonised_Lissage_Filtrage(cur_sujet,cur_activity,cur_acquisition,rep_global,type_filtre);
                            catch
                                log_error{end+1}='erreur de IK';
                            end
                        end %IK
                        
                        % ID
%                         if strcmp(st_protocole.FONCTION_A_LANCER.ID{1},'1')
%                             try
%                                 pipeline_harmonised_ID(st_protocole,cur_sujet,cur_activity,...
%                                     cur_acquisition,rep_global,myosim_Matlab_name_unconstrained,...
%                                     f_filtre_ID,plugin_STJ);
%                             catch
%                                 log_error{end+1}='erreur de ID';
%                             end
%                         end % if ID
                        
                        % ANALYZE
                        if 1%strcmp(st_protocole.FONCTION_A_LANCER.BodyKinematics{1},'1') || ...
                             %   strcmp(st_protocole.FONCTION_A_LANCER.MuscleAnalysis{1},'1') || ...
                             %   strcmp(st_protocole.FONCTION_A_LANCER.MomentArms{1},'1')
                            try
                                pipeline_harmonised_ANALYZE(cur_sujet,cur_activity,cur_acquisition,rep_global,myosim_Matlab_name,st_protocole,plugin_STJ);
                                
                            catch
                                log_error{end+1}='erreur de Analyze';
                            end
                        end % if Analyze
                        
                        if strcmp(st_protocole.FONCTION_A_LANCER.RMSE{1},'1')
                            [RMSE_global,Table_RMSE,RMSE_partiel]=OS_CalculMarqueursVirtuelAnalyse...
                                (rep_global,cur_sujet,cur_activity,...
                                cur_acquisition,...
                                struct_OSIM,st_protocole);
                        end
                        
                        % IK methods comparison
                        if isfield(st_protocole.FONCTION_A_LANCER,'ANALYSE_ERREUR_SCAPULA')
                            if strcmp(st_protocole.FONCTION_A_LANCER.ANALYSE_ERREUR_SCAPULA{1},'1') 
                             
                             % opensim ik ellipsoid fonctionnel     
                             TRTH_OS = scapula_os_ik(repertoire_sujet,cur_activity,cur_acquisition,struct_OSIM);   
                             % cluster ik 
                             TRTH_CL = scapula_cluster_ik(repertoire_sujet,cur_activity,cur_acquisition);      
                             % scapula locator ik
                             [TRTH_SL,TRSL_SC,sign] = scapula_locator_ik(repertoire_sujet,cur_activity,cur_acquisition,cur_static,struct_OSIM);
                             
                             % errors
                             Angles_OS = Mat2Angle_xyz(TRTH_OS(1:3,1:3,1)*[0 0 1;0 1 0;-1 0 0],sign)
                             Angles_CL = Mat2Angle_xyz(TRTH_CL(1:3,1:3,1),sign)
                             Angles_SL = Mat2Angle_xyz(TRTH_SL(1:3,1:3,1),sign)
                             [Err_CL_Translation,Err_CL_Axe_Angle,Err_CL_Euler] = scapula_kinematics_errors(TRTH_CL,TRTH_SL,size_interp,sign);
                             [Err_OS_Translation,Err_OS_Axe_Angle,Err_OS_Euler] = scapula_kinematics_errors(TRTH_OS,TRTH_SL,size_interp,sign);
                             
                             % unique matrix : rows are time events,
                             %                  columns are errors axe(1:3),angle(4),trans(5),euler(6:8)
                             %                             & trial id iacquisition(9),iactivity(10),isujet(11)            
                             ERR_CL=[ERR_CL; Err_CL_Axe_Angle Err_CL_Translation' Err_CL_Euler ...
                                             repmat([i_acquisition i_activity i_sujet],size_interp,1)];
                             ERR_OS=[ERR_OS; Err_OS_Axe_Angle Err_OS_Translation' Err_OS_Euler ...
                                             repmat([i_acquisition i_activity i_sujet],size_interp)];
                            end %if erreur scapula
                        end %if isfield erreur scapula
                        
                        if isfield(st_protocole.FONCTION_A_LANCER,'ANALYSE_MUSCLE_PERSO')
                            if strcmp(st_protocole.FONCTION_A_LANCER.ANALYSE_MUSCLE_PERSO{1},'1')
                                [Struct_IK_ISB,Struct_dist_CoR] = OS_AnalyseMusclePerso(rep_global,cur_sujet,cur_activity,...
                                    cur_acquisition,myosim_Matlab_name,struct_OSIM,Struct_OSIM_gen);  
                            end % if Muscle Perso
                        end % if isfield analyse_muscle_perso
                        
                    end % if pour exclure les ik_virt

                end % for i_acquisition               
            
        % Show CL errors
        err2plot = permute(reshape([ERR_CL(ERR_CL(:,10)==i_activity&ERR_CL(:,11)==i_sujet,1:8)],...
                            size_interp,i_acquisition,1,8),... % martix shape: 1_iframe,2_icquisition,3_CLvsOS,4_erros_index
                            [1 4 2 3]);                         % matrix dim : 1_iframe,2_erros_index,3_icquisition,4_CLvsOS  
%         plot_errors_during_phases(cur_activity,phases,err2plot(:,1:3,:),err2plot(:,4,:),err2plot(:,5,:),err2plot(:,6:8,:));
        mean_ERR_CL = [mean_ERR_CL; squeeze(nanmean(reshape(ERR_CL(ERR_CL(:,10)==i_activity&ERR_CL(:,11)==i_sujet,1:8),size_interp*nb_phase,i_acquisition/nb_phase,8),2))  ...
                                             repmat([i_activity i_sujet],size_interp*nb_phase,1)];
        
        % Show CL vs. OS errors
        err2plot = permute(reshape([ERR_CL(ERR_CL(:,10)==i_activity&ERR_CL(:,11)==i_sujet,1:8);...
                                    ERR_OS(ERR_OS(:,10)==i_activity&ERR_OS(:,11)==i_sujet,1:8)],...
                            size_interp,nb_acquisition,2,8),... % martix shape: 1_iframe,2_icquisition,,3_CLvsOS,4_erros_index
                            [1 4 2 3]);                         % matrix dim : 1_iframe,2_erros_index,3_icquisition,4_CLvsOS  
        plot_errors_during_phases(cur_activity,phases,err2plot(:,1:3,:,1),err2plot(:,4,:,1),err2plot(:,5,:,1),err2plot(:,6:8,:,1));
        plot_errors_during_phases(cur_activity,phases,err2plot(:,1:3,:,2),err2plot(:,4,:,2),err2plot(:,5,:,2),err2plot(:,6:8,:,2));
        legend_models={'CL','','OS',''};
        plot_meanerror_during_phases(cur_activity,err2plot(:,1:3,:,:),err2plot(:,4,:,:),err2plot(:,5,:,:),err2plot(:,6:8,:,:),legend_models);
        
end % for i_sujet 

%% Post_Traitement

% Show CL errors
err2plot = permute(reshape([mean_ERR_CL(mean_ERR_CL(:,9)==i_activity,1:8)],...
                            size_interp,i_sujet*nb_phase,1,8),... % martix shape: 1_iframe,2_isujet,3_CLvsOS,4_erros_index
                            [1 4 2 3]);                         % matrix dim : 1_iframe,2_erros_index,3_isujet,4_CLvsOS  
plot_errors_during_phases(cur_activity,phases,err2plot(:,1:3,:),err2plot(:,4,:),err2plot(:,5,:),err2plot(:,6:8,:));
      
%         % Show CL vs. OS errors
% err2plot = permute(reshape([ERR_CL(ERR_CL(:,10)==iactivity&&ERR_CL(:,11)==isujet,1:8);...
%                     ERR_OS(ERR_OS(:,10)==iactivity&&ERR_OS(:,11)==isujet,1:8)],...
%                     size_interp,nb_acquisition,2,8),...
%                     [1 4 2 3]); % matrix dim : 1_iframe,2_erros_index,3_icquisition,4_CLvsOS  
% plot_errors_during_phases(cur_activity,phases,err2plot(:,1:3,:,1),err2plot(4,:,1),err2plot(:,5,:,1),err2plot(:,6:8,:,1));
% plot_errors_during_phases(cur_activity,phases,err2plot(:,1:3,:,2),err2plot(4,:,2),err2plot(:,5,:,2),err2plot(:,6:8,:,2));

%         plot_meanerror_during_phases(cur_activity,err2plot(:,1:3,:,:),err2plot(4,:,:),err2plot(:,5,:,:),err2plot(:,6:8,:,:));

%     error_compare(Err_CL_Translation_mean,Err_CL_Translation_std,...
%                     Err_OS_Translation_mean,Err_OS_Translation_std)

%   end % if pour exclure les dossiers hors task
end % for i_activity

EcritureLogError(log_error,fullfile(rep_global,'info_global','log_error.txt'));