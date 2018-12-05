function [Moment_abduction,Moment_internalrotation,Moment_flexion] = Calcul_Dyn_Inv(rep_global,my_sujet,my_activity)

rep_sujet = ['rep_global_' my_sujet] ;
[~,my_file] = PathContent_Type(fullfile(rep_global,rep_sujet,my_sujet,my_activity),'id.sto') ;
my_file = my_file{1} ;
my_file = my_file(1:end-7);
myID = load_sto_file(fullfile(rep_global,rep_sujet,my_sujet,my_activity,[my_file '_id.sto'])) ;

% Torseur MC / R_FRM
myMOT = load_sto_file(fullfile(rep_global,rep_sujet,my_sujet,my_activity,[my_file '.mot'])) ;

% Lecture modèle
[~,model_file] = PathContent_Type(fullfile(rep_global,rep_sujet,my_sujet,'modele'),'model_final.osim') ;
model_file = model_file{1} ;
[tree, ~, ~] = xml_readOSIM_TJ(fullfile(rep_global,rep_sujet,my_sujet,'modele',model_file), struct('Sequence',true));
[Bodies, Joints] = extract_KinChainData_ModelOS(tree);


% Loader les fichiers d'ANALYZE
position_file_name = [model_file(1:end-5) '_BodyKinematics_pos_global.sto'];
myPOS_STO = load_sto_file(fullfile(rep_global,rep_sujet,my_sujet,my_activity,[my_file '_ANALYZE'],position_file_name)) ;
n_frame = length(myPOS_STO.hand_r_Ox);

%% Etape 1 : transport du torseur MC dans R0
Mat_E = [myMOT.rhf_vx , myMOT.rhf_vy, myMOT.rhf_vz,myMOT.rhtorque_x,myMOT.rhtorque_y,myMOT.rhtorque_z] ;
Mat_S = Mat2D_2_MH(Mat_E,'dynamique',1);

MH_R0_R_main(4,4,n_frame) = 0;
Torseur_MC_R0(4,4,n_frame) = 0;

for i_time = 1:n_frame

M_x_R_main = Mrot_rotation_axe_angle([1 0 0],myPOS_STO.hand_r_Ox(i_time),'degrees');
M_y_R_main = Mrot_rotation_axe_angle([0 1 0],myPOS_STO.hand_r_Oy(i_time),'degrees');
M_z_R_main = Mrot_rotation_axe_angle([0 0 1],myPOS_STO.hand_r_Oz(i_time),'degrees');

MH_R0_R_main(1:3,1:3,i_time) = M_x_R_main * M_y_R_main * M_z_R_main ;
MH_R0_R_main(:,4,i_time) = [myPOS_STO.hand_r_X(i_time) , myPOS_STO.hand_r_Y(i_time), myPOS_STO.hand_r_Z(i_time) , 1]' ;

Torseur_MC_R0(:,:,i_time) = changement_repere_Legnani(Mat_S(:,:,i_time),MH_R0_R_main(:,:,i_time),eye(4,4),'dynamique');

end

%% Etape 2 : calcul du torseur d'efforts du poids
%index des bodies du modèle
idx_main = find(strcmp(fieldnames(Bodies),'hand_r')) ;
idx_radius = find(strcmp(fieldnames(Bodies),'radius_r')) ;
idx_ulna = find(strcmp(fieldnames(Bodies),'ulna_r')) ;
idx_humerus = find(strcmp(fieldnames(Bodies),'humerus_r')) ;

masse_main = tree.Model.BodySet.objects.Body(idx_main).mass ; % ATTENTION : idx_main en DUR
Torseur_poids_main_R0 = [repmat([0 -masse_main*9.81 0],n_frame,1),...
    cross([myPOS_STO.hand_r_X, myPOS_STO.hand_r_Y, myPOS_STO.hand_r_Z],repmat([0 -masse_main*9.81 0],n_frame,1))];
Torseur_poids_main_R0_H = Mat2D_2_MH(Torseur_poids_main_R0,'dynamique',1);

masse_radius = tree.Model.BodySet.objects.Body(idx_radius).mass ; % ATTENTION : idx en DUR
Torseur_poids_radius_R0 = [repmat([0 -masse_radius*9.81 0],n_frame,1),...
    cross([myPOS_STO.radius_r_X, myPOS_STO.radius_r_Y, myPOS_STO.radius_r_Z],repmat([0 -masse_radius*9.81 0],n_frame,1))];
Torseur_poids_radius_R0_H = Mat2D_2_MH(Torseur_poids_radius_R0,'dynamique',1);

masse_ulna = tree.Model.BodySet.objects.Body(idx_ulna).mass ; % ATTENTION : idx en DUR
Torseur_poids_ulna_R0 = [repmat([0 -masse_ulna*9.81 0],n_frame,1),...
    cross([myPOS_STO.ulna_r_X, myPOS_STO.ulna_r_Y, myPOS_STO.ulna_r_Z],repmat([0 -masse_ulna*9.81 0],n_frame,1))];
Torseur_poids_ulna_R0_H = Mat2D_2_MH(Torseur_poids_ulna_R0,'dynamique',1);

masse_humerus = tree.Model.BodySet.objects.Body(idx_humerus).mass ; % ATTENTION : idx en DUR
Torseur_poids_humerus_R0 = [repmat([0 -masse_humerus*9.81 0],n_frame,1),...
    cross([myPOS_STO.humerus_r_X, myPOS_STO.humerus_r_Y, myPOS_STO.humerus_r_Z],repmat([0 -masse_humerus*9.81 0],n_frame,1))];
Torseur_poids_humerus_R0_H = Mat2D_2_MH(Torseur_poids_humerus_R0,'dynamique',1);

%% Etape 3 : calcul du torseur dynamique de la main
acc_file_name = [model_file(1:end-5) '_BodyKinematics_acc_global.sto'];
myACC_STO = load_sto_file(fullfile(rep_global,rep_sujet,my_sujet,my_activity,[my_file '_ANALYZE'],acc_file_name)) ;

vel_file_name = [model_file(1:end-5) '_BodyKinematics_vel_global.sto'];
myVEL_STO = load_sto_file(fullfile(rep_global,rep_sujet,my_sujet,my_activity,[my_file '_ANALYZE'],vel_file_name)) ;
[myACC_STO] = derivation_vel_sto_OS(myVEL_STO);

J_main = [tree.Model.BodySet.objects.Body(idx_main).inertia_xx ,...
          tree.Model.BodySet.objects.Body(idx_main).inertia_xy ,...
          tree.Model.BodySet.objects.Body(idx_main).inertia_xz ; ...
          tree.Model.BodySet.objects.Body(idx_main).inertia_xy ,...
          tree.Model.BodySet.objects.Body(idx_main).inertia_yy ,...
          tree.Model.BodySet.objects.Body(idx_main).inertia_yz ;...
          tree.Model.BodySet.objects.Body(idx_main).inertia_xz ,...
          tree.Model.BodySet.objects.Body(idx_main).inertia_yz ,...
          tree.Model.BodySet.objects.Body(idx_main).inertia_zz ] ;
      
Acc_ang_Rm = pi/180*[myACC_STO.hand_r_Ox,myACC_STO.hand_r_Oy,myACC_STO.hand_r_Oz] ;

% Torseur dyn de la main en G_main, exprimé dans le repère R_main
Moment_Dyn_Main_Rmain = J_main * Acc_ang_Rm' ;
Moment_Dyn_Main_Rmain = Moment_Dyn_Main_Rmain' ;
Res_Dyn_Main_Rmain = masse_main * [myACC_STO.hand_r_X,myACC_STO.hand_r_Y,myACC_STO.hand_r_Z];
Torseur_Dyn_Rmain_H = Mat2D_2_MH([Res_Dyn_Main_Rmain,Moment_Dyn_Main_Rmain],'dynamique',1);

% Ajout partie transport
Torseur_Dyn_Main_R0(4,4,n_frame) = 0 ;

for i_time = 1:n_frame
    
    Torseur_Dyn_Main_R0(:,:,i_time) = changement_repere_Legnani(Torseur_Dyn_Rmain_H(:,:,i_time),MH_R0_R_main(:,:,i_time),eye(4,4),'dynamique') ;    
    
end

% Etape 5 : itération pour avant-bras et bras
%% Radius
MH_R0_R_radius(4,4,n_frame) = 0;

for i_time = 1:n_frame

M_x_R_radius = Mrot_rotation_axe_angle([1 0 0],myPOS_STO.radius_r_Ox(i_time),'degrees');
M_y_R_radius = Mrot_rotation_axe_angle([0 1 0],myPOS_STO.radius_r_Oy(i_time),'degrees');
M_z_R_radius = Mrot_rotation_axe_angle([0 0 1],myPOS_STO.radius_r_Oz(i_time),'degrees');

MH_R0_R_radius(1:3,1:3,i_time) = M_x_R_radius * M_y_R_radius * M_z_R_radius ;
MH_R0_R_radius(:,4,i_time) = [myPOS_STO.radius_r_X(i_time) , myPOS_STO.radius_r_Y(i_time), myPOS_STO.radius_r_Z(i_time) , 1]' ;

end

J_radius = [tree.Model.BodySet.objects.Body(idx_radius).inertia_xx ,...
          tree.Model.BodySet.objects.Body(idx_radius).inertia_xy ,...
          tree.Model.BodySet.objects.Body(idx_radius).inertia_xz ; ...
          tree.Model.BodySet.objects.Body(idx_radius).inertia_xy ,...
          tree.Model.BodySet.objects.Body(idx_radius).inertia_yy ,...
          tree.Model.BodySet.objects.Body(idx_radius).inertia_yz ;...
          tree.Model.BodySet.objects.Body(idx_radius).inertia_xz ,...
          tree.Model.BodySet.objects.Body(idx_radius).inertia_yz ,...
          tree.Model.BodySet.objects.Body(idx_radius).inertia_zz ] ;
      
Acc_ang_Rradius = pi/180*[myACC_STO.radius_r_Ox,myACC_STO.radius_r_Oy,myACC_STO.radius_r_Oz] ;
% Torseur dyn de la main en G_main, exprimé dans le repère R_main
Moment_Dyn_Radius_Rradius = J_radius * Acc_ang_Rradius' ;
Moment_Dyn_Radius_Rradius = Moment_Dyn_Radius_Rradius' ;
Res_Dyn_Radius_Rradius = masse_radius * [myACC_STO.radius_r_X,myACC_STO.radius_r_Y,myACC_STO.radius_r_Z];
Torseur_Dyn_Rradius_H = Mat2D_2_MH([Res_Dyn_Radius_Rradius,Moment_Dyn_Radius_Rradius],'dynamique',1);

% Ajout partie transport
Torseur_Dyn_Radius_R0(4,4,n_frame) = 0 ;

for i_time = 1:n_frame
    
    Torseur_Dyn_Radius_R0(:,:,i_time) = changement_repere_Legnani(Torseur_Dyn_Rradius_H(:,:,i_time),...
        MH_R0_R_radius(:,:,i_time),eye(4,4),'dynamique') ;    
    
end

%% Ulna
MH_R0_R_ulna(4,4,n_frame) = 0;

for i_time = 1:n_frame

M_x_R_ulna = Mrot_rotation_axe_angle([1 0 0],myPOS_STO.ulna_r_Ox(i_time),'degrees');
M_y_R_ulna = Mrot_rotation_axe_angle([0 1 0],myPOS_STO.ulna_r_Oy(i_time),'degrees');
M_z_R_ulna = Mrot_rotation_axe_angle([0 0 1],myPOS_STO.ulna_r_Oz(i_time),'degrees');

MH_R0_R_ulna(1:3,1:3,i_time) = M_x_R_ulna * M_y_R_ulna * M_z_R_ulna ;
MH_R0_R_ulna(:,4,i_time) = [myPOS_STO.ulna_r_X(i_time) , myPOS_STO.ulna_r_Y(i_time), myPOS_STO.ulna_r_Z(i_time) , 1]' ;

end

J_ulna = [tree.Model.BodySet.objects.Body(idx_ulna).inertia_xx ,...
          tree.Model.BodySet.objects.Body(idx_ulna).inertia_xy ,...
          tree.Model.BodySet.objects.Body(idx_ulna).inertia_xz ; ...
          tree.Model.BodySet.objects.Body(idx_ulna).inertia_xy ,...
          tree.Model.BodySet.objects.Body(idx_ulna).inertia_yy ,...
          tree.Model.BodySet.objects.Body(idx_ulna).inertia_yz ;...
          tree.Model.BodySet.objects.Body(idx_ulna).inertia_xz ,...
          tree.Model.BodySet.objects.Body(idx_ulna).inertia_yz ,...
          tree.Model.BodySet.objects.Body(idx_ulna).inertia_zz ] ;
      
Acc_ang_Rulna = pi/180*[myACC_STO.ulna_r_Ox,myACC_STO.ulna_r_Oy,myACC_STO.ulna_r_Oz] ;
% Torseur dyn de la main en G_main, exprimé dans le repère R_main
Moment_Dyn_Ulna_Rulna = J_ulna * Acc_ang_Rulna' ;
Moment_Dyn_Ulna_Rulna = Moment_Dyn_Ulna_Rulna' ;
Res_Dyn_Ulna_Rulna = masse_ulna * [myACC_STO.ulna_r_X,myACC_STO.ulna_r_Y,myACC_STO.ulna_r_Z];
Torseur_Dyn_Rulna_H = Mat2D_2_MH([Res_Dyn_Ulna_Rulna,Moment_Dyn_Ulna_Rulna],'dynamique',1);

% Ajout partie transport
Torseur_Dyn_Ulna_R0(4,4,n_frame) = 0 ;

for i_time = 1:n_frame
    
    Torseur_Dyn_Ulna_R0(:,:,i_time) = changement_repere_Legnani(Torseur_Dyn_Rulna_H(:,:,i_time),...
        MH_R0_R_ulna(:,:,i_time),eye(4,4),'dynamique') ;    
    
end

%% Bras
MH_R0_R_humerus(4,4,n_frame) = 0;

for i_time = 1:n_frame

M_x_R_humerus = Mrot_rotation_axe_angle([1 0 0],myPOS_STO.humerus_r_Ox(i_time),'degrees');
M_y_R_humerus = Mrot_rotation_axe_angle([0 1 0],myPOS_STO.humerus_r_Oy(i_time),'degrees');
M_z_R_humerus = Mrot_rotation_axe_angle([0 0 1],myPOS_STO.humerus_r_Oz(i_time),'degrees');

MH_R0_R_humerus(1:3,1:3,i_time) = M_x_R_humerus * M_y_R_humerus * M_z_R_humerus ;
MH_R0_R_humerus(:,4,i_time) = [myPOS_STO.humerus_r_X(i_time) , myPOS_STO.humerus_r_Y(i_time), myPOS_STO.humerus_r_Z(i_time) , 1]' ;

end

J_humerus = [tree.Model.BodySet.objects.Body(idx_humerus).inertia_xx ,...
          tree.Model.BodySet.objects.Body(idx_humerus).inertia_xy ,...
          tree.Model.BodySet.objects.Body(idx_humerus).inertia_xz ; ...
          tree.Model.BodySet.objects.Body(idx_humerus).inertia_xy ,...
          tree.Model.BodySet.objects.Body(idx_humerus).inertia_yy ,...
          tree.Model.BodySet.objects.Body(idx_humerus).inertia_yz ;...
          tree.Model.BodySet.objects.Body(idx_humerus).inertia_xz ,...
          tree.Model.BodySet.objects.Body(idx_humerus).inertia_yz ,...
          tree.Model.BodySet.objects.Body(idx_humerus).inertia_zz ] ;
      
Acc_ang_Rhumerus = pi/180*[myACC_STO.humerus_r_Ox,myACC_STO.humerus_r_Oy,myACC_STO.humerus_r_Oz] ;

% Torseur dyn de la main en G_main, exprimé dans le repère R_main
Moment_Dyn_Humerus_Rhumerus = J_humerus * Acc_ang_Rhumerus' ;
Moment_Dyn_Humerus_Rhumerus = Moment_Dyn_Humerus_Rhumerus' ;
Res_Dyn_Humerus_Rhumerus = masse_humerus * [myACC_STO.humerus_r_X,myACC_STO.humerus_r_Y,myACC_STO.humerus_r_Z];
Torseur_Dyn_Rhumerus_H = Mat2D_2_MH([Res_Dyn_Humerus_Rhumerus,Moment_Dyn_Humerus_Rhumerus],'dynamique',1);

% Ajout partie transport
Torseur_Dyn_Humerus_R0(4,4,n_frame) = 0 ;

for i_time = 1:n_frame
    
    Torseur_Dyn_Humerus_R0(:,:,i_time) = changement_repere_Legnani(Torseur_Dyn_Rhumerus_H(:,:,i_time),...
        MH_R0_R_humerus(:,:,i_time),eye(4,4),'dynamique') ;    
    
end

%% Etape 6 : Récupérer le centre de la glénohumérale

COM_GH_Rloc = tree.Model.BodySet.objects.Body(idx_humerus).mass_center ;

GH_R0(n_frame,3)=0;
%Position de la glène dans R0
for i_time = 1:n_frame
GH_R0(i_time,:) = (MH_R0_R_humerus(1:3,1:3,i_time)*COM_GH_Rloc')' + [myPOS_STO.humerus_r_X(i_time),...
    myPOS_STO.humerus_r_Y(i_time), myPOS_STO.humerus_r_Z(i_time)] ;
end

%% Etape 7/8 : Exprimer le torseur à la glène + changer dans Rthorax
MH_R0_R_thorax(4,4,n_frame) = 0;

Dyn_main_Rthorax(4,4,n_frame) = 0 ;
Dyn_radius_Rthorax(4,4,n_frame) = 0 ;
Dyn_ulna_Rthorax(4,4,n_frame) = 0 ;
Dyn_humerus_Rthorax(4,4,n_frame) = 0 ;

Torseur_Poids_main_Rthorax(4,4,n_frame) = 0 ;
Torseur_Poids_radius_Rthorax(4,4,n_frame) = 0 ;
Torseur_Poids_ulna_Rthorax(4,4,n_frame) = 0 ;
Torseur_Poids_humerus_Rthorax(4,4,n_frame) = 0 ;

Torseur_Effort_MC_Rthorax(4,4,n_frame)= 0 ;

for i_time = 1:n_frame

M_x_R_thorax = Mrot_rotation_axe_angle([1 0 0],myPOS_STO.thorax_Ox(i_time),'degrees');
M_y_R_thorax = Mrot_rotation_axe_angle([0 1 0],myPOS_STO.thorax_Oy(i_time),'degrees');
M_z_R_thorax = Mrot_rotation_axe_angle([0 0 1],myPOS_STO.thorax_Oz(i_time),'degrees');

MH_R0_R_thorax(1:3,1:3,i_time) = M_x_R_thorax * M_y_R_thorax * M_z_R_thorax ;
MH_R0_R_thorax(:,4,i_time) = [GH_R0(i_time,:), 1]' ;

% Partie Dynamique 
Dyn_main_Rthorax(:,:,i_time) = changement_repere_Legnani(Torseur_Dyn_Main_R0(:,:,i_time),eye(4,4),MH_R0_R_thorax(:,:,i_time),'dynamique') ;
Dyn_radius_Rthorax(:,:,i_time) = changement_repere_Legnani(Torseur_Dyn_Radius_R0(:,:,i_time),eye(4,4),MH_R0_R_thorax(:,:,i_time),'dynamique') ;
Dyn_ulna_Rthorax(:,:,i_time) = changement_repere_Legnani(Torseur_Dyn_Ulna_R0(:,:,i_time),eye(4,4),MH_R0_R_thorax(:,:,i_time),'dynamique') ;
Dyn_humerus_Rthorax(:,:,i_time) = changement_repere_Legnani(Torseur_Dyn_Humerus_R0(:,:,i_time),eye(4,4),MH_R0_R_thorax(:,:,i_time),'dynamique') ;

% Partie Torseur du poids
Torseur_Poids_main_Rthorax(:,:,i_time) = changement_repere_Legnani(Torseur_poids_main_R0_H(:,:,i_time),eye(4,4),MH_R0_R_thorax(:,:,i_time),'dynamique') ;
Torseur_Poids_radius_Rthorax(:,:,i_time) = changement_repere_Legnani(Torseur_poids_radius_R0_H(:,:,i_time),eye(4,4),MH_R0_R_thorax(:,:,i_time),'dynamique') ;
Torseur_Poids_ulna_Rthorax(:,:,i_time) = changement_repere_Legnani(Torseur_poids_ulna_R0_H(:,:,i_time),eye(4,4),MH_R0_R_thorax(:,:,i_time),'dynamique');
Torseur_Poids_humerus_Rthorax(:,:,i_time) = changement_repere_Legnani(Torseur_poids_humerus_R0_H(:,:,i_time),eye(4,4),MH_R0_R_thorax(:,:,i_time),'dynamique');

% Partie Effort Main Courante
Torseur_Effort_MC_Rthorax(:,:,i_time) = changement_repere_Legnani(Torseur_MC_R0(:,:,i_time),eye(4,4),MH_R0_R_thorax(:,:,i_time),'dynamique');

end

Dyn_UL_Rthorax = Dyn_main_Rthorax + Dyn_radius_Rthorax + Dyn_ulna_Rthorax + Dyn_humerus_Rthorax ;
Dyn_UL_Rthorax_col = Mat2D_2_MH(Dyn_UL_Rthorax,'dynamique',-1);

Torseur_Poids_UL_Rthorax = Torseur_Poids_main_Rthorax + Torseur_Poids_radius_Rthorax + ...
Torseur_Poids_ulna_Rthorax + Torseur_Poids_humerus_Rthorax ;
Torseur_Poids_UL_Rthorax_col = Mat2D_2_MH(Torseur_Poids_UL_Rthorax,'dynamique',-1) ;

Torseur_Effort_MC_Rthorax_col = Mat2D_2_MH(Torseur_Effort_MC_Rthorax,'dynamique',-1) ;

NJM_Epaule_Rthorax = Dyn_UL_Rthorax - Torseur_Poids_UL_Rthorax - Torseur_Effort_MC_Rthorax ;
NJM_Epaule_Rthorax_col = Mat2D_2_MH(NJM_Epaule_Rthorax,'dynamique',-1) ;

Moment_abduction = NJM_Epaule_Rthorax_col(:,4) ;
Moment_internalrotation = NJM_Epaule_Rthorax_col(:,5) ;
Moment_flexion = NJM_Epaule_Rthorax_col(:,6) ;

time_int = linspace(0,100,100) ;
temps_ini = myID.time ;
time_ini = linspace(0,100,length(temps_ini));
Moment_abduction = interp1(time_ini(1:length(Moment_abduction)),Moment_abduction,time_int,'spline') ;
Moment_internalrotation = interp1(time_ini(1:length(Moment_internalrotation)),Moment_internalrotation,time_int,'spline') ;
Moment_flexion = interp1(time_ini(1:length(Moment_flexion)),Moment_flexion,time_int,'spline') ;


end