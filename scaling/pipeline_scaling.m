function [ myosim_scaled_path,struct_OSIM ]=pipeline_scaling(file_model_gen,rep_global,st_protocol,cur_sujet,cur_mass,cur_static,cur_activity,plugin_STJ)

    
%1) INITIALIZE: On récupère les chemins 

rep_model = fullfile(rep_global,cur_sujet,'modele');
rep_prot=(fullfile(rep_global,'info_global'));
[~,file_prot]=PathContent_Type(rep_prot,'.protOS');

%2) SCALING
  
%2.1 SCALING DIMENSIONS
    %2.1.1. Scaling dimensions des segments (sauf clusters)
    file_model_geom = pipeline_harmonised_scaling(rep_global,cur_static,...
                    st_protocol,cur_sujet, rep_model,char(fullfile(rep_prot,file_model_gen)),...
                        cur_mass,plugin_STJ,'scaling_1');
    
%2.2 SCALING STJoint
% Détecter si le modèle possède un Scapulothoracic Joint
res = IsthereSTJ(fullfile(rep_model,file_model_geom));                    
if res == 1 %STJ
    %2.2.1. Scaling de la contrainte point de contact acromion
    file_model_acromion = OS_scaling_PointConstraint(rep_model,char(fullfile(rep_prot,file_model_gen)));
      
    %2.2.2. Finalisation du modele ellipsoide scalé geométriquement
    %(scaling_1)
    file_model_final = pipeline_harmonised_scaling(rep_global,cur_static,...
                        st_protocol,cur_sujet, rep_model,char(fullfile(rep_model,file_model_acromion)),...
                            cur_mass,plugin_STJ,'scaling_1');
    
    if isfield(st_protocol.FONCTION_A_LANCER,'Ellipsoide_Fonctionnel')
        if st_protocol.FONCTION_A_LANCER.Ellipsoide_Fonctionnel{1}==1
            %2.2.3. Scaling de l'éllipsoïde
            path_static_mot = fullfile(rep_model,[cur_sujet '_' cur_activity '_scaling_1_motion.mot']);
            file_model_ellipsoid = pipeline_scaling_ellipsoid(rep_global,cur_sujet,cur_activity,cur_static,file_model_acromion,path_static_mot);


            %2.2.4. Finalisation du modèle ellispoide fonctionnel ('scaling_2')
            file_model_final = pipeline_harmonised_scaling(rep_global,cur_static,...
                                 st_protocol,cur_sujet,rep_model,[rep_model filesep file_model_ellipsoid],...
                                     cur_mass,plugin_STJ,'scaling_2');
        end
    end
end

    % !! Cette méthode ne fonctionne pas pour tous les fichiers de statique
    % !! cas : FRM fonction pour un fichier de statique prise milieu de
    % !! poussée, mais pas un scap_stat.

myosim_scaled_path = fullfile(rep_model,file_model_final);
[struct_OSIM,~,~] = xml_readOSIM_TJ(myosim_scaled_path,struct('Sequence',true));
save(char(fullfile(rep_model,[file_model_final(1:end-5) '.mat'])),'struct_OSIM');
end