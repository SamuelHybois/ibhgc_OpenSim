function [Struct_BL]=calcul_bras_de_levier_TE(Struct_MH,Wraps,Struct_L,...
Struct_muscles_points,Struct_muscle_wraps,Struct_wrapping_points,Struct_MH_ISB,Struct_IK_ISB,Bodies,Joints)
% Fonctionne pour une seule frame
i_f =1;
clear Liste
%% 1) Lister les muscles qui croisent le complexe de l'épaule
liste_m=fieldnames(Struct_muscles_points);
Liste_joint_shoulder = {'sternoclavicular_l','acromioclavicular_l','glenohumeral_l','scapulothoracic_l'};
for i_m =2 :length(liste_m)
    Muscle = liste_m{i_m};
    Liste.(Muscle)= ListeJointCroiseMuscle(Muscle,Struct_muscles_points,Bodies,Joints);
    
    bool1 = ~isempty(find(~cellfun(@isempty,strfind(Liste.(Muscle),Liste_joint_shoulder(1)))==1, 1));
    bool2 = ~isempty(find(~cellfun(@isempty,strfind(Liste.(Muscle),Liste_joint_shoulder(2)))==1, 1));
    bool3 = ~isempty(find(~cellfun(@isempty,strfind(Liste.(Muscle),Liste_joint_shoulder(3)))==1, 1));
    bool4 = ~isempty(find(~cellfun(@isempty,strfind(Liste.(Muscle),Liste_joint_shoulder(4)))==1, 1));
    
    
    if bool1 || bool2 || bool3 || bool4
    Liste_Epaule.(Muscle)=Liste.(Muscle);
    end
end

%% 4) Lister les coordonnées généralisées issues de la décomposition des matrices

Mat_alpha = [Struct_IK_ISB.sternoclavicular_l.angles(:,:,i_f)';...
Struct_IK_ISB.acromioclavicular_l.angles(:,:,i_f)';...
Struct_IK_ISB.glenohumeral_l.angles(:,:,i_f)'];

%% 5) Faire varier autour de la position d'équilibre chaque degrés de liberté ~+ou-0.5°
axe=eye(3,3);
for i_a=1:length(Mat_alpha)
    %% 6) Modifier la matrice de transformation concernée
    % pour quatres frames (-0.5:0.25:0.5) en degré
    Delta_t=0.25;
    t=-0.5:Delta_t:0.5;
    
    a_mod = Mat_alpha(i_a) + t;
    
    Mat_alpha_mod = repmat(Mat_alpha,[1,5]);
    Mat_alpha_mod(i_a,:)=a_mod;
    
    %% 7) Modification d'une coordonnée generalisée entraine la modification de la matrice de transformation
    % Modification de la matrice de transformation pour 4 frames 
    
    %Recomposer la matrice de rotation
    for i_jt_mod = 1:size(Mat_alpha_mod,1)/3
        for i_delta = 1:size(Mat_alpha_mod,2)
            for i=1:3
                M_rot{i}=Mrot_rotation_axe_angle(axe(:,i),Mat_alpha_mod((i-1)*3+1,i_delta));
            end
            MH_total.(Liste_joint_shoulder{i_jt_mod})(1:3,1:3,i_delta)=[M_rot{1}*M_rot{2}*M_rot{3},[1,1,1]';[0 0 0],1];
        end
    end
    %%%%%%%%%%%%%%%%%%%%% Fonction pas finis
    %%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 8) On modifie les matrices de passage des segments enfants dans MH_R0_Rs
    for i_d = 1 :length(t)
        
       Struct_MH_ISB.clavicle_l.MH = Struct_MH.Thorax.MH(:,:,i_d) * MH_total.sternoclavicular_l(:,:,i_d);
        
    end
    
    %% 9) calcul longueur musculaire
    %Fonction calcul longueur musculaire
    
    %% 8) Détecter les varations de longueurs musculaires pour les muscles
    for i_muscles=1:length(Struct_muscles_points)
        for i_frames=1:nb_frames
            Delta_L(i_frames) = Struct_L.muscle(:,:,i_frames+1)-Struct_L.muscle(:,:,i_frames);

        end
        if  mean(Delta_L)~=0
            Muscle.BL=Delta_L/Delta_theta;
        end
           
    end
    
end
end
