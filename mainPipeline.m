% %% Récupération des données du dossier info_global
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
if isempty(nom_modele_mat)  %On regarde si le modèle existe en .mat. Si non, on le crée
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
try
    base_expression = st_protocole.PARAMETRES_OPENSIM.base_expression_ID ; % Proximal, Distal ou JCS
catch
    base_expression='Proximal';
end

%% Boucle Sujets
sujets=fieldnames(st_protocole.SUJETS);
if strcmp(sujets{1},'all')
    [my_sujets,~] = PathContent(rep_global);
else
    my_sujets=sujets;
end
reserved_dir_without_info_global = {'.','..','.DS_Store','info_global','Info_global','Info_Global','modele','fichiers_wrl','Statique','MvtsFonctionnels'} ; % pour enlever les dossiers fantômes .,..,DS_store (mac)
log_error={};


for i_sujet =1:length(my_sujets) 
    if isempty(find(strcmp(my_sujets(i_sujet),reserved_dir_without_info_global),1))
        % Nom du sujet courant
        cur_sujet=char(my_sujets(i_sujet));
        log_error{end+1}=cur_sujet;
        rep_sortie_model=fullfile(rep_global,cur_sujet,'modele');
        [~,cur_static_name]=PathContent_Type(rep_sortie_model,'.trc');
        cur_static=char(fullfile(rep_sortie_model,cur_static_name));
        % Lecture de la masse du sujet courant
        % Manque calcul masse modèle (% de la masse ex: fauteuil) à mettre
        % dans le prot
        try
            cur_mass = cur_sujet_mass(structure_excel,st_protocole,cur_sujet);
        catch
            cur_mass=NaN;
            log_error{end+1}='masse du sujet non renseignée';
        end
        
        %SCALING
        if st_protocole.FONCTION_A_LANCER.Scaling{1}~='0'
%             try
                if isfield(st_protocole,'SCALING_MASSE')
                    cur_mass=(str2double(st_protocole.SCALING_MASSE.prop_mass_model{1})/100)*cur_mass; % Permet de prendre en compte que le modèle ne fait pas 100% du poids du sujet
                end
                if st_protocole.FONCTION_A_LANCER.Scaling{1}=='1'
                    [myosim_Matlab_name,struct_OSIM] = pipeline_scaling(nom_modele_osim{1},rep_global,...
                        st_protocole,cur_sujet,cur_mass,cur_static,'',plugin_STJ);

                elseif st_protocole.FONCTION_A_LANCER.Scaling{1}=='2'
                    % Scaling perso
                    myosim_Matlab_name=[nom_modele_osim{1}(1:end-5),'_scaled.osim'];
                    [ ~,struct_OSIM ]=pipeline_scaling_sans_OS(nom_modele_osim{1},rep_global,st_protocole,cur_sujet,cur_mass,myosim_Matlab_name);
                else
                    log_error{end+1}='scaling non effectué';
                end
%             catch
%                 log_error{end+1}='scaling non effectué';
%             end
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
                    perso_cheville=st_protocole.PERSONNALISATION.chaine_cinematique{3};
%                     try
                        chaine_a_evaluer=strcat('model_perso_EOS=',st_protocole.PERSONNALISATION.chaine_cinematique{2},'(rep_global,cur_sujet,struct_OSIM,st_protocole,perso_cheville);');
                        eval(chaine_a_evaluer)
                        myosim_Matlab_name=fullfile(rep_global,cur_sujet,'modele',[cur_sujet,'_perso_EOS.osim']);
                        xml_writeOSIM_TJ(myosim_Matlab_name,model_perso_EOS,'OpenSimDocument');
%                     catch
%                         disp(['Sujet ',cur_sujet,' non personnalisé'])
%                     end
                end
            end
        end
        % Création du modèle sans contraintes pour ID et Analyze plus
        % rapide
        
        myosim_Matlab_name_unconstrained = Unconstrain_Model(myosim_Matlab_name);
        
        %% Boucle activités
        repertoire_activites = fullfile(rep_global,cur_sujet);
        [my_activities,~] = PathContent(repertoire_activites);
        
        for i_activity = 1:length(my_activities)
            if isempty( find(strcmp(my_activities(i_activity),reserved_dir_without_info_global),1))
                
                cur_activity=char(my_activities(i_activity));
                log_error{end+1}=cur_activity;
                
                % Récupération de tous les fichiers trc de l'activité
                [~,my_acquisitions] = PathContent_Type(fullfile(repertoire_activites,cur_activity),'.trc');
                
                for i_acquisition=1:length(my_acquisitions)
                    
                    cur_acquisition=char(my_acquisitions(i_acquisition));
                    
                    if isempty(strfind(cur_acquisition,'ik_virt'))
                        
                        % IK
                        if st_protocole.FONCTION_A_LANCER.IK{1}~='0'
                            try
                                if st_protocole.FONCTION_A_LANCER.IK{1}=='1'
                                    pipeline_harmonised_IK(st_protocole,cur_sujet,...
                                        cur_activity,cur_acquisition,myosim_Matlab_name,rep_global,...
                                        tolerance_contrainte_ik,plugin_STJ,rep_toolbox);
                                    
                                    pipeline_harmonised_Lissage_Filtrage(cur_sujet,cur_activity,cur_acquisition,rep_global,type_filtre);

                                elseif st_protocole.FONCTION_A_LANCER.IK{1}=='2'
                                    % IK perso
                                    disp('Ajoute l''IK avec Matlab si tu veux utiliser cette option')
                                end
                            catch
                                log_error{end+1}='erreur de IK';
                            end
                            
                        end
                        % ID
                        if st_protocole.FONCTION_A_LANCER.ID{1}~='0'

                            %                             try
                            if st_protocole.FONCTION_A_LANCER.ID{1}=='1'
                                pipeline_harmonised_ID(st_protocole,cur_sujet,cur_activity,...
                                    cur_acquisition,rep_global,myosim_Matlab_name_unconstrained,...
                                    f_filtre_ID,plugin_STJ);
                            elseif st_protocole.FONCTION_A_LANCER.ID{1}=='2'
                                % ID perso
                                [~]=pipeline_ID_sans_OS(rep_global,cur_sujet,cur_activity,...
                                    cur_acquisition,st_protocole,myosim_Matlab_name_unconstrained,...
                                    base_expression);
                            else
                                log_error{end+1}='pas de ID';
                            end
                            %                             catch
                            %                                 log_error{end+1}='erreur de ID';
                            %                             end

                        end % if ID
                        % ANALYZE
                        if strcmp(st_protocole.FONCTION_A_LANCER.BodyKinematics{1},'1') || ...
                                strcmp(st_protocole.FONCTION_A_LANCER.MuscleAnalysis{1},'1') || ...
                                strcmp(st_protocole.FONCTION_A_LANCER.MomentArms{1},'1')
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
                        if isfield(st_protocole.FONCTION_A_LANCER,'ANALYSE_MUSCLE_PERSO')
                            if strcmp(st_protocole.FONCTION_A_LANCER.ANALYSE_MUSCLE_PERSO{1},'1')
                                [Struct_IK_ISB,Struct_dist_CoR] = OS_AnalyseMusclePerso(rep_global,cur_sujet,cur_activity,...
                                    cur_acquisition,myosim_Matlab_name,struct_OSIM,Struct_OSIM_gen);
                            end % if Muscle Perso
                        end % if isfield analyse_muscle_perso
                        
                    end % if pour exclure les ik_virt
                    
                end % for i_acquisition
                
            end % if pour exclure les dossiers hors task
            
        end % for i_activity
        
    end
end % for i_sujet

EcritureLogError(log_error,fullfile(rep_global,'info_global','log_error.txt'));
