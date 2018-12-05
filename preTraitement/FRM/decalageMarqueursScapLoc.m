<<<<<<< HEAD
function [st_marqueurs_cine] = decalageMarqueursScapLoc(st_marqueurs_cine,d_ScapLoc)
=======
function [st_marqueurs_cine] = decalageMarqueursScapLoc(st_marqueurs_cine,d_ScapLoc,sign)
>>>>>>> dev_diane_ENSAM

nFrames = size(st_marqueurs_cine.SCLM,1) ;

for i_time = 1:nFrames
    
    SCLM_i_frame = st_marqueurs_cine.SCLM(i_time,:);
    SCLB_i_frame = st_marqueurs_cine.SCLB(i_time,:);
    SCLL_i_frame = st_marqueurs_cine.SCLL(i_time,:);
    
    SCLHM_i_frame = st_marqueurs_cine.SCLHM(i_time,:);
    SCLHL_i_frame = st_marqueurs_cine.SCLHL(i_time,:);
    
<<<<<<< HEAD
    
=======
>>>>>>> dev_diane_ENSAM
    % Recalage vertical ScapLoc
    u1 = (SCLHM_i_frame - SCLB_i_frame)./norm(SCLHM_i_frame - SCLB_i_frame);
    u2 = (SCLHL_i_frame - SCLB_i_frame)./norm(SCLHL_i_frame - SCLB_i_frame);
    normale_plan_ScapLoc = cross(u1,u2)./norm(cross(u1,u2));
    
<<<<<<< HEAD
    SCLM_i_frame = SCLM_i_frame + d_ScapLoc.*normale_plan_ScapLoc ;
    SCLB_i_frame = SCLB_i_frame + d_ScapLoc.*normale_plan_ScapLoc ;
    SCLL_i_frame = SCLL_i_frame + d_ScapLoc.*normale_plan_ScapLoc ;
=======
    SCLM_i_frame = SCLM_i_frame + sign*d_ScapLoc.*normale_plan_ScapLoc ;
    SCLB_i_frame = SCLB_i_frame + sign*d_ScapLoc.*normale_plan_ScapLoc ;
    SCLL_i_frame = SCLL_i_frame + sign*d_ScapLoc.*normale_plan_ScapLoc ;
    SCLHL_i_frame = SCLHL_i_frame + sign*d_ScapLoc.*normale_plan_ScapLoc ;
    SCLHM_i_frame = SCLHM_i_frame + sign*d_ScapLoc.*normale_plan_ScapLoc ;
>>>>>>> dev_diane_ENSAM
    
    st_marqueurs_cine.SCLM(i_time,:) = SCLM_i_frame ;
    st_marqueurs_cine.SCLB(i_time,:) = SCLB_i_frame ;
    st_marqueurs_cine.SCLL(i_time,:) = SCLL_i_frame ;
<<<<<<< HEAD
=======
    st_marqueurs_cine.SCLHL(i_time,:) = SCLHL_i_frame ;
    st_marqueurs_cine.SCLHM(i_time,:) = SCLHM_i_frame ;
>>>>>>> dev_diane_ENSAM
    
end


end