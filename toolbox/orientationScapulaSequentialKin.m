%%%Abstract 3D AHM
% mytrc_path = 'E:\OneDrive - ensam.eu\PhD\Publications\2018\3DAHM\Resultats\reTraitementJuin2018\Tennis_R_serve_03.trc' ;
mytrc_path = 'C:\Users\visiteur\Documents\Sourcetree_OSPipeline\dataTest\rep_global_FRMB\AM02SH\ScapLoc\Tennis_R_serve_03.trc' ;
% Récupérer le struct_MH après l'IK.
%load('E:\MusculoSkeletalModelling\ModeleScapula\traitementOpenSim_scalingSansContrainte\SP01SM\basket_shoot\basket_05_ANALYZE\Struct_MH.mat') ;
dist_SL = 0.08 ; %distance entre les palpeurs/marqueurs du SL

% Coordonnées des marqueurs à reconstruire dans le modèle OpenSim
SCLL_RscapOS =  [-0.0432971 ; -0.00462663 ; 0.00951149  ] ;
SCLB_RscapOS =  [-0.118695 ; -0.120113 ; -0.100525 ] ;
SCLM_RscapOS =  [-0.0918929 ; -0.00951589 ; -0.108397 ] ;
MAN_RthoraxOS_loc = [0.0394329 ; -0.0394329 ; 0 ] ;
XYP_RthoraxOS_loc = [0.0888812 ; -0.19446 ; 0.00842362 ] ;
T8_RthoraxOS_loc =  [-0.166608 ; -0.15977 ; -0.00113183 ] ;
C7_RthoraxOS_loc =  [-0.0895111 ; 0.062184 ; 0.00578875 ] ;


%% Création du repère Thorax_Vicon

% Lecture des marqueurs dans le .trc
SCLM_RVicon = lire_coord_marqueur_trc('SCLM',mytrc_path) ;
SCLB_RVicon = lire_coord_marqueur_trc('SCLB',mytrc_path) ;
SCLL_RVicon = lire_coord_marqueur_trc('SCLL',mytrc_path) ;
SCLHL_RVicon = lire_coord_marqueur_trc('SCLHL',mytrc_path) ;
SCLHM_RVicon = lire_coord_marqueur_trc('SCLHM',mytrc_path) ;
ACD_RVicon = lire_coord_marqueur_trc('ACD',mytrc_path) ;
MAN_RVicon = lire_coord_marqueur_trc('MAN',mytrc_path) ;
C7_RVicon = lire_coord_marqueur_trc('C7',mytrc_path) ;
T8_RVicon = lire_coord_marqueur_trc('T8',mytrc_path) ;
XYP_RVicon = lire_coord_marqueur_trc('XYP',mytrc_path) ;
MTACDL_RVicon = lire_coord_marqueur_trc('MTACDL',mytrc_path) ;
MTACDM_RVicon = lire_coord_marqueur_trc('MTACDM',mytrc_path) ;
MTACDB_RVicon = lire_coord_marqueur_trc('MTACDB',mytrc_path) ;

nFrames = size(SCLM_RVicon,1) ;
P_R_Vicon_R_thorax(4,4,nFrames) = 0 ;

for i_time = 1:nFrames
    %%% scapula locator
    SCLM_i_frame = SCLM_RVicon(i_time,:) ;
    SCLB_i_frame = SCLB_RVicon(i_time,:) ;
    SCLL_i_frame = SCLL_RVicon(i_time,:) ;
    SCLHM_i_frame = SCLHM_RVicon(i_time,:);
    SCLHL_i_frame = SCLHL_RVicon(i_time,:) ;
    
    % Recalage vertical ScapLoc
    u1 = (SCLHM_i_frame - SCLB_i_frame)./norm(SCLHM_i_frame - SCLB_i_frame);
    u2 = (SCLHL_i_frame - SCLB_i_frame)./norm(SCLHL_i_frame - SCLB_i_frame);
    normale_plan_ScapLoc = cross(u1,u2)./norm(cross(u1,u2));
    
    SCLM_RVicon(i_time,:) = SCLM_i_frame + dist_SL.*normale_plan_ScapLoc ;
    SCLB_RVicon(i_time,:) = SCLB_i_frame + dist_SL.*normale_plan_ScapLoc ;
    SCLL_RVicon(i_time,:) = SCLL_i_frame + dist_SL.*normale_plan_ScapLoc ;
    SCLHL_RVicon(i_time,:) = SCLHL_i_frame + dist_SL.*normale_plan_ScapLoc ;
    SCLHM_RVicon(i_time,:) = SCLHM_i_frame + dist_SL.*normale_plan_ScapLoc ;
    
    % Construction du repère thorax (ISB, Wu 2005)
    MAN = MAN_RVicon(i_time,:);
    XYP = XYP_RVicon(i_time,:) ;
    ACD = ACD_RVicon(i_time,:) ;
    C7 = C7_RVicon(i_time,:) ;
    T8 = T8_RVicon(i_time,:) ;
    
    mid_C7_MAN = (C7+MAN)./2 ;
    mid_T8_XYP = (XYP+T8)./2 ;
    
    Y_1_RthoraxVicon = (mid_C7_MAN - mid_T8_XYP)./norm(mid_C7_MAN - mid_T8_XYP);
    Z_01_RthoraxVicon = cross(MAN-mid_T8_XYP,C7-mid_T8_XYP)./norm(cross(MAN-mid_T8_XYP,C7-mid_T8_XYP));
    X_1_RthoraxVicon = cross(Y_1_RthoraxVicon,Z_01_RthoraxVicon)./norm(cross(Y_1_RthoraxVicon,Z_01_RthoraxVicon));
    Z_1_RthoraxVicon = cross(X_1_RthoraxVicon,Y_1_RthoraxVicon)./norm(cross(X_1_RthoraxVicon,Y_1_RthoraxVicon));
    
    % Matrice de passage du repère Vicon au repère Thorax
    P_R_Vicon_R_thorax(:,:,i_time) = [[X_1_RthoraxVicon' , Y_1_RthoraxVicon', Z_1_RthoraxVicon' , MAN'] ; [0 0 0 1] ] ;
    
end


%% Méthode 1 : tracking de la scapula avec le ScapLoc : position réelle
SCLM_Rthorax(nFrames,3)=0;
SCLB_Rthorax(nFrames,3)=0;
SCLL_Rthorax(nFrames,3)=0;
SCLHL_Rthorax(nFrames,3)=0;
SCLHM_Rthorax(nFrames,3)=0;
P_Rthorax_RScaploc = zeros(4,4,nFrames) ;
rotX_Scaploc_Rthorax = zeros(1,nFrames) ;
rotY_Scaploc_Rthorax = zeros(1,nFrames) ;
rotZ_Scaploc_Rthorax = zeros(1,nFrames) ;

MTACDL_Rthorax(nFrames,3)=0;
MTACDM_Rthorax(nFrames,3)=0;
MTACDB_Rthorax(nFrames,3)=0;
P_Rthorax_RCluster = zeros(4,4,nFrames) ;
rotXCluster_Rthorax = zeros(1,nFrames) ;
rotYCluster_Rthorax = zeros(1,nFrames) ;
rotZCluster_Rthorax = zeros(1,nFrames) ;


% Transport des coordonnées dans Rthorax
for i_time = 1:nFrames
    %%% scapula locator
    SCLM_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[SCLM_RVicon(i_time,:), 1]' ;
    SCLM_Rthorax(i_time,:) = SCLM_Rthorax_tmp(1:3);
    SCLB_Rthorax_tmp= P_R_Vicon_R_thorax(:,:,i_time)\[SCLB_RVicon(i_time,:), 1]' ;
    SCLB_Rthorax(i_time,:) = SCLB_Rthorax_tmp(1:3) ;
    SCLL_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[SCLL_RVicon(i_time,:), 1]' ;
    SCLL_Rthorax(i_time,:) =SCLL_Rthorax_tmp(1:3) ;
    SCLHL_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[SCLHL_RVicon(i_time,:), 1]' ;
    SCLHL_Rthorax(i_time,:) =SCLHL_Rthorax_tmp(1:3) ;
    SCLHM_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[SCLHM_RVicon(i_time,:), 1]' ;
    SCLHM_Rthorax(i_time,:) =SCLHM_Rthorax_tmp(1:3) ;
    
    z_scaploc = (SCLL_Rthorax_tmp(1:3) - SCLM_Rthorax_tmp(1:3))./norm(SCLL_Rthorax_tmp(1:3) - SCLM_Rthorax_tmp(1:3));
    x_scaploc = cross(SCLM_Rthorax_tmp(1:3)-SCLB_Rthorax_tmp(1:3),SCLL_Rthorax_tmp(1:3)-SCLB_Rthorax_tmp(1:3))./...
        norm(cross(SCLM_Rthorax_tmp(1:3)-SCLB_Rthorax_tmp(1:3),SCLL_Rthorax_tmp(1:3)-SCLB_Rthorax_tmp(1:3)));
    y_scaploc = cross(z_scaploc,x_scaploc)./norm(cross(z_scaploc,x_scaploc));
    x_scaploc = cross(x_scaploc,y_scaploc);
    
    P_Rthorax_RScaploc(:,:,i_time) = ...
        [ x_scaploc , y_scaploc , z_scaploc , SCLL_Rthorax_tmp(1:3) ; [0 0 0 1]] ;
    
    tmp_mat1 = [ x_scaploc , y_scaploc , z_scaploc] ;
    tmp_angles1 = axemobile_yxz(tmp_mat1) ;
    rotX_Scaploc_Rthorax(i_time)=tmp_angles1(1) ;
    rotY_Scaploc_Rthorax(i_time)=tmp_angles1(2) ;
    rotZ_Scaploc_Rthorax(i_time)=tmp_angles1(3) ;
    
    %%% scapula cluster
    MTACDL_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[MTACDL_RVicon(i_time,:), 1]' ;
    MTACDL_Rthorax(i_time,:) = MTACDL_Rthorax_tmp(1:3);
    MTACDM_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[MTACDM_RVicon(i_time,:), 1]' ;
    MTACDM_Rthorax(i_time,:) = MTACDM_Rthorax_tmp(1:3);
    MTACDB_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[MTACDB_RVicon(i_time,:), 1]' ;
    MTACDB_Rthorax(i_time,:) = MTACDB_Rthorax_tmp(1:3);
    
    
    u1 = (MTACDM_Rthorax_tmp(1:3) - MTACDB_Rthorax_tmp(1:3))./norm(MTACDM_Rthorax_tmp(1:3) - MTACDB_Rthorax_tmp(1:3));
    u2 = (MTACDL_Rthorax_tmp(1:3) - MTACDB_Rthorax_tmp(1:3))./norm(MTACDL_Rthorax_tmp(1:3) - MTACDB_Rthorax_tmp(1:3));
    normale_plan_ScapClust= cross(u1,u2)./norm(cross(u1,u2));
    x_tmp = normale_plan_ScapClust ;
    z_tmp = (MTACDL_Rthorax_tmp(1:3) - MTACDM_Rthorax_tmp(1:3))./norm(MTACDL_Rthorax_tmp(1:3) - MTACDM_Rthorax_tmp(1:3));
    y_tmp = cross(z_tmp,x_tmp)./norm(cross(z_tmp,x_tmp)) ;
    P_Rthorax_RCluster(:,:,i_time) = ...
        [ x_tmp , y_tmp , z_tmp , MTACDL_Rthorax_tmp(1:3) ; [0 0 0 1]] ;
    
    tmp_mat = [ x_tmp , y_tmp , z_tmp] ;
    tmp_angles = axemobile_yxz(tmp_mat) ;
    rotXCluster_Rthorax(i_time)=tmp_angles(1) ;
    rotYCluster_Rthorax(i_time)=tmp_angles(2) ;
    rotZCluster_Rthorax(i_time)=tmp_angles(3) ;
    
end

%% Méthode 2 : tracking de la scapula avec le ScapLoc : position recalée à partir du cluster

% On recale en position statique le cluster par rapport au ScapLoc
frame_recalage = 2 ;
P_RCluster_RScaploc = inv(P_Rthorax_RCluster(:,:,frame_recalage))* P_Rthorax_RScaploc(:,:,frame_recalage);

% Estimation de l'orientation scapula à partir du cluster
P_R_SL_thorax_estim = zeros(4,4,nFrames) ;
rotXScaploc_Rthorax_estim(1,nFrames)=0 ;
rotYScaploc_Rthorax_estim(1,nFrames)=0 ;
rotZScaploc_Rthorax_estim(1,nFrames)=0 ;

SCLL_clust_vect=zeros(nFrames,3) ;
SCLB_clust_vect=zeros(nFrames,3) ;
SCLM_clust_vect=zeros(nFrames,3) ;

for i=1:nFrames
    P_Rthorax_RScaploc_estim_tmp = P_Rthorax_RCluster(:,:,i)*P_RCluster_RScaploc ;
    SCLL_clust_vect(i,:) = P_Rthorax_RScaploc_estim_tmp(1:3,4)' ;
    %     SCLB_clust_vect(i) = ;
    %     SCLM_clust_vect(i) = ;
    tmp_angles_estim = axemobile_yxz(P_Rthorax_RScaploc_estim_tmp) ;
    rotXScaploc_Rthorax_estim(i)=tmp_angles_estim(1) ;
    rotYScaploc_Rthorax_estim(i)=tmp_angles_estim(2) ;
    rotZScaploc_Rthorax_estim(i)=tmp_angles_estim(3) ;
end

%% Méthode 3 : estimation de l'orientation de la scapula à partir du MMS + MKO
% !!! Nécessite un Struct_MH en sortie de l'IK !!!

nFrames = size(Struct_MH.scapula_r.MH,3) ;
SCLL_MKO_vect=zeros(nFrames,3) ;
SCLB_MKO_vect=zeros(nFrames,3) ;
SCLM_MKO_vect=zeros(nFrames,3) ;
MAN_MKO_vect=zeros(nFrames,3) ;
C7_MKO_vect=zeros(nFrames,3) ;
T8_MKO_vect=zeros(nFrames,3) ;
XYP_MKO_vect=zeros(nFrames,3) ;

SCLM_RthoraxOS=zeros(nFrames,3) ;
SCLB_RthoraxOS=zeros(nFrames,3) ;
SCLL_RthoraxOS=zeros(nFrames,3) ;
T8_RthoraxOS=zeros(nFrames,3) ;
C7_RthoraxOS=zeros(nFrames,3) ;
MAN_RthoraxOS=zeros(nFrames,3) ;
XYP_RthoraxOS=zeros(nFrames,3) ;

matHomogeneScaploc_MKO = zeros(4,4,nFrames) ;
P_R_ground_R_thorax = zeros(4,4,nFrames) ;
P_Rthorax_RScaploc_OS = zeros(4,4,nFrames) ;
rotX_Scaploc_Rthorax_MKO = zeros(1,nFrames) ;
rotY_Scaploc_Rthorax_MKO = zeros(1,nFrames) ;
rotZ_Scaploc_Rthorax_MKO = zeros(1,nFrames) ;

for i_time = 1:nFrames
    
    %%%%% Reconstruction des markers virtuels IK dans le repère ground
    %%% Scapula
    M_pass_ground_Scaploc_tmp =  Struct_MH.scapula_r.MH(:,:,i_time) ;
    %SCLL
    SCLL_MKO = M_pass_ground_Scaploc_tmp*[SCLL_RscapOS;1] ;
    SCLL_MKO =  SCLL_MKO(1:3) ;
    SCLL_MKO_vect(i_time,:) = SCLL_MKO ;
    %SCLB
    SCLB_MKO = M_pass_ground_Scaploc_tmp*[SCLB_RscapOS;1] ;
    SCLB_MKO =  SCLB_MKO(1:3) ;
    SCLB_MKO_vect(i_time,:) = SCLB_MKO ;
    %SCLM
    SCLM_MKO = M_pass_ground_Scaploc_tmp*[SCLM_RscapOS;1] ;
    SCLM_MKO =  SCLM_MKO(1:3) ;
    SCLM_MKO_vect(i_time,:) = SCLM_MKO ;
    
    %%% Thorax
    M_pass_ground_thorax_tmp =  Struct_MH.thorax.MH(:,:,i_time) ;
    %MAN
    MAN_MKO = M_pass_ground_thorax_tmp*[MAN_RthoraxOS_loc;1] ;
    MAN_MKO =  MAN_MKO(1:3) ;
    MAN_MKO_vect(i_time,:) = MAN_MKO ;
    %C7
    C7_MKO = M_pass_ground_thorax_tmp*[C7_RthoraxOS_loc;1] ;
    C7_MKO = C7_MKO(1:3) ;
    C7_MKO_vect(i_time,:) = C7_MKO ;
    %T8
    T8_MKO = M_pass_ground_thorax_tmp*[T8_RthoraxOS_loc;1] ;
    T8_MKO =  T8_MKO(1:3) ;
    T8_MKO_vect(i_time,:) = T8_MKO ;
    %XYP
    XYP_MKO = M_pass_ground_thorax_tmp*[XYP_RthoraxOS_loc;1] ;
    XYP_MKO =  XYP_MKO(1:3) ;
    XYP_MKO_vect(i_time,:) = XYP_MKO ;
    
    
    %%%%% Expression dans le repère thorax
    % Matrice de passage du repère ground au repère Thorax
    OS_mid_C7_MAN = (C7_MKO+MAN_MKO)./2 ;
    OS_mid_T8_XYP = (XYP_MKO+T8_MKO)./2 ;
    
    Y_1_RthoraxOS = (OS_mid_C7_MAN - OS_mid_T8_XYP)./norm(OS_mid_C7_MAN - OS_mid_T8_XYP);
    Z_01_RthoraxOS = cross(MAN_MKO-OS_mid_T8_XYP,C7_MKO-OS_mid_T8_XYP)./norm(cross(MAN_MKO-OS_mid_T8_XYP,C7_MKO-OS_mid_T8_XYP));
    X_1_RthoraxOS = cross(Y_1_RthoraxOS,Z_01_RthoraxOS)./norm(cross(Y_1_RthoraxOS,Z_01_RthoraxOS));
    Z_1_RthoraxOS = cross(X_1_RthoraxOS,Y_1_RthoraxOS)./norm(cross(X_1_RthoraxOS,Y_1_RthoraxOS));
    P_R_ground_R_thorax(:,:,i_time) = [[X_1_RthoraxOS , Y_1_RthoraxOS, Z_1_RthoraxOS , MAN_MKO] ; [0 0 0 1] ] ;
    
    
    %%%%% Expression dans le repère thoraxOS
    %SCLM
    SCLM_RthoraxOS_tmp = P_R_ground_R_thorax(:,:,i_time)\[SCLM_MKO; 1] ;
    SCLM_RthoraxOS(i_time,:) = SCLM_RthoraxOS_tmp(1:3);
    %SCLB
    SCLB_RthoraxOS_tmp = P_R_ground_R_thorax(:,:,i_time)\[SCLB_MKO; 1] ;
    SCLB_RthoraxOS(i_time,:) = SCLB_RthoraxOS_tmp(1:3);
    %SCLL
    SCLL_RthoraxOS_tmp = P_R_ground_R_thorax(:,:,i_time)\[SCLL_MKO; 1] ;
    SCLL_RthoraxOS(i_time,:) = SCLL_RthoraxOS_tmp(1:3);
    %MAN
    MAN_RthoraxOS_tmp = P_R_ground_R_thorax(:,:,i_time)\[MAN_MKO; 1] ;
    MAN_RthoraxOS(i_time,:) = MAN_RthoraxOS_tmp(1:3);
    %XYP
    XYP_RthoraxOS_tmp = P_R_ground_R_thorax(:,:,i_time)\[XYP_MKO; 1] ;
    XYP_RthoraxOS(i_time,:) = XYP_RthoraxOS_tmp(1:3);
    %C7
    C7_RthoraxOS_tmp = P_R_ground_R_thorax(:,:,i_time)\[C7_MKO; 1] ;
    C7_RthoraxOS(i_time,:) = C7_RthoraxOS_tmp(1:3);
    %T8
    T8_RthoraxOS_tmp = P_R_ground_R_thorax(:,:,i_time)\[T8_MKO; 1] ;
    T8_RthoraxOS(i_time,:) = T8_RthoraxOS_tmp(1:3);
    
    
    %%%%% Matrice de passage de R_thoraxOS à RScaploc_OS
    z_scaploc_OS = (SCLL_RthoraxOS_tmp(1:3) - SCLM_RthoraxOS_tmp(1:3))./norm(SCLL_RthoraxOS_tmp(1:3) - SCLM_RthoraxOS_tmp(1:3));
    x_scaploc_OS = cross(SCLM_RthoraxOS_tmp(1:3)-SCLB_RthoraxOS_tmp(1:3),SCLL_RthoraxOS_tmp(1:3)-SCLB_RthoraxOS_tmp(1:3))./...
        norm(cross(SCLM_RthoraxOS_tmp(1:3)-SCLB_RthoraxOS_tmp(1:3),SCLL_RthoraxOS_tmp(1:3)-SCLB_RthoraxOS_tmp(1:3)));
    y_scaploc_OS = cross(z_scaploc_OS,x_scaploc_OS)./norm(cross(z_scaploc_OS,x_scaploc_OS));
    x_scaploc_OS = cross(x_scaploc_OS,y_scaploc_OS);
    
    P_Rthorax_RScaploc_OS(:,:,i_time) = ...
        [ x_scaploc_OS , y_scaploc_OS , z_scaploc_OS , SCLL_RthoraxOS_tmp(1:3) ; [0 0 0 1]] ;
    
    tmp_mat_MKO = [ x_scaploc_OS , y_scaploc_OS , z_scaploc_OS] ;
    tmp_angles_MKO = axemobile_yxz(tmp_mat_MKO) ;
    rotX_Scaploc_Rthorax_MKO(i_time)=tmp_angles_MKO(1) ;
    rotY_Scaploc_Rthorax_MKO(i_time)=tmp_angles_MKO(2) ;
    rotZ_Scaploc_Rthorax_MKO(i_time)=tmp_angles_MKO(3) ;
end
