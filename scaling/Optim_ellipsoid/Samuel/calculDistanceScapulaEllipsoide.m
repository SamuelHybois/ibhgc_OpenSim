function distanceMoyenneEllipsoide = calculDistanceScapulaEllipsoide(path_c3d,t_debut,t_fin,varEllipsoide)
loc_ellipsoid = varEllipsoide(1:3) ;
dim_ellipsoid = varEllipsoide(4:6) ;
my_c3d = btk_loadc3d(path_c3d) ;
[my_c3d] = NettoieMarkerLabels(my_c3d.marker_data.Markers);
dist_SL = 0.09 ; %distance entre les palpeurs/marqueurs du SL
nFrames = size(my_c3d.SCLM,1) ;

%% Création du repère Thorax_Vicon
P_R_Vicon_R_thorax(4,4,nFrames) = 0 ;
SCLM_RVicon(nFrames,3)=0 ;
SCLB_RVicon(nFrames,3)=0 ;
SCLL_RVicon(nFrames,3)=0 ;
ACD_RVicon(nFrames,3)=0 ;
MAN_RVicon(nFrames,3)=0 ;

for i_time = 1:nFrames
    
    SCLM_i_frame = my_c3d.SCLM(i_time,:)./1000 ;
    SCLB_i_frame = my_c3d.SCLB(i_time,:)./1000 ;
    SCLL_i_frame = my_c3d.SCLL(i_time,:)./1000 ;
    
    SCLHM_i_frame = my_c3d.SCLHM(i_time,:)./1000 ;
    SCLHL_i_frame = my_c3d.SCLHL(i_time,:)./1000 ;
    
    
    % Recalage vertical ScapLoc
    u1 = (SCLHM_i_frame - SCLB_i_frame)./norm(SCLHM_i_frame - SCLB_i_frame);
    u2 = (SCLHL_i_frame - SCLB_i_frame)./norm(SCLHL_i_frame - SCLB_i_frame);
    normale_plan_ScapLoc = cross(u1,u2)./norm(cross(u1,u2));
    
    SCLM_RVicon(i_time,:) = SCLM_i_frame + dist_SL.*normale_plan_ScapLoc ;
    SCLB_RVicon(i_time,:) = SCLB_i_frame + dist_SL.*normale_plan_ScapLoc ;
    SCLL_RVicon(i_time,:) = SCLL_i_frame + dist_SL.*normale_plan_ScapLoc ;
    MAN = my_c3d.MAN(i_time,:)./1000 ;
    MAN_RVicon(i_time,:) = MAN ;
    XYP = my_c3d.XYP(i_time,:)./1000 ;
    ACD = my_c3d.ACD(i_time,:)./1000 ;
    ACD_RVicon(i_time,:) = ACD ;
    
    Y_1_RthoraxVicon = (MAN - XYP)./norm(MAN - XYP);
    Z_01_RthoraxVicon = (ACD - MAN)./norm(ACD - MAN);
    X_1_RthoraxVicon = cross(Y_1_RthoraxVicon,Z_01_RthoraxVicon)./norm(cross(Y_1_RthoraxVicon,Z_01_RthoraxVicon));
    Z_1_RthoraxVicon = cross(X_1_RthoraxVicon,Y_1_RthoraxVicon)./norm(cross(X_1_RthoraxVicon,Y_1_RthoraxVicon));
    
    P_R_Vicon_R_thorax(:,:,i_time) = [[X_1_RthoraxVicon' , Y_1_RthoraxVicon', Z_1_RthoraxVicon' , MAN'] ; [0 0 0 1] ] ;
end

SCLM_Rthorax(nFrames,3)=0;
SCLB_Rthorax(nFrames,3)=0;
SCLL_Rthorax(nFrames,3)=0;
ACD_Rthorax(nFrames,3)=0;
MAN_Rthorax(nFrames,3)=0;

% Transport des coordonnées dans Rthorax
for i_time = 1:nFrames
    SCLM_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[SCLM_RVicon(i_time,:), 1]' ;
    SCLM_Rthorax(i_time,:) = SCLM_Rthorax_tmp(1:3);
    SCLB_Rthorax_tmp= P_R_Vicon_R_thorax(:,:,i_time)\[SCLB_RVicon(i_time,:), 1]' ;
    SCLB_Rthorax(i_time,:) = SCLB_Rthorax_tmp(1:3) ;
    SCLL_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[SCLL_RVicon(i_time,:), 1]' ;
    SCLL_Rthorax(i_time,:) =SCLL_Rthorax_tmp(1:3) ;
    ACD_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[ACD_RVicon(i_time,:), 1]' ;
    ACD_Rthorax(i_time,:) = ACD_Rthorax_tmp(1:3);
    MAN_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[MAN_RVicon(i_time,:), 1]' ;
    MAN_Rthorax(i_time,:) = MAN_Rthorax_tmp(1:3);
end


U = eye(3,3) ;

d_SCLM(t_fin-t_debut+1) = 0 ;
d_SCLL(t_fin-t_debut+1) = 0 ;
d_SCLB(t_fin-t_debut+1) = 0 ;
i_t = 0 ;
for i_time = [t_debut:1:t_fin]
    
    i_t = i_t + 1 ;

% SCL médial
d_SCLM(i_t) = distancePointEllipsoide(SCLM_Rthorax(i_time,:),dim_ellipsoid,loc_ellipsoid) ;

% SCL latéral
d_SCLL(i_t) = distancePointEllipsoide(SCLL_Rthorax(i_time,:),dim_ellipsoid,loc_ellipsoid) ;

% SCL bas
d_SCLB(i_t) = distancePointEllipsoide(SCLB_Rthorax(i_time,:),dim_ellipsoid,loc_ellipsoid) ;

end

distanceMoyenneEllipsoide = (mean(d_SCLM)+mean(d_SCLL)+mean(d_SCLB))/3 ;

end
