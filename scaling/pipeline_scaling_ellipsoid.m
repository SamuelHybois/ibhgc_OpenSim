function     file_model_ellipsoid = pipeline_scaling_ellipsoid(rep_global,cur_sujet,cur_activity,cur_static,file_model_gen,path_static_mot)
                         
% This pipeline is made to calibrate fonctionnaly the scapulothoracic
% ellipsoid on which the centre of scapula slides
%
% INPUTS
% path_global : full path of the current study
% cur_sujet : folder of the subject's data for which the ellipsoid is personnalized
% file_model_gen : osim generic model  file name
% file_static : trc file path of markers coordinates of static calibration trial
%
% OUTPUTS
% file_model_ellipsoid : osim file name for model with personnalized ellipsoids 
% 
%                                                                           D. Haering 16.oct.2018
%

%% 0. INITIALIZE

%0.1.Modele osim
rep_model = char(fullfile(rep_global,cur_sujet,'modele',file_model_gen));
fid = fopen(rep_model);
text = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
fclose(fid);
nbline = numel(text{1});
st_model = xml_readOSIM_TJ(rep_model);
 
%0.2. Donnees de calibration statique 
%0.2.1. Coordonnées des marqueurs en position de reference
st_trc = lire_donnees_trc(cur_static);
%0.2.2. Coordonnées du modèle en postition de reference
[~,~,st_mot] = lire_donnees_mot(path_static_mot);

%0.3 Donnees de calibration dynamique
% rep_cur_dynamic = fullfile(path_global,cur_sujet,'MvtsFonctionnels');
rep_cur_dynamic = fullfile(rep_global,cur_sujet,cur_activity);
[~,list_file_dynamic] = PathContent_Type(rep_cur_dynamic,'.trc');

%0.4 Identification du/des cotes du modele
if sum(~isempty(strfind(text{1},'ScapulothoracicEllipsoid')))==1
    sign = [1 -1];
    true_ellipsoid_sign = []; %cote present
    true_ellipsoid_line = [];
    true_joint_line = [];
    sign_char_en={'R','L'};
    sign_char_fr={'D','G'};
    ellipsoid_name={'ScapulothoracicEllipsoid_r','ScapulothoracicEllipsoid_l'};
    ellipsoid_joint={'scapulothoracic_r','scapulothoracic_l'};

%     test_r = find(contains(text{1},ellipsoid_name{1}));%matlab2017
    test_r = find(~cellfun(@isempty,strfind(text{1},ellipsoid_name{1})));
    if ~isempty(test_r)
            true_ellipsoid_sign =  [true_ellipsoid_sign 1];
            true_ellipsoid_line =  [true_ellipsoid_line test_r];
            true_joint_line = [true_joint_line find(~cellfun(@isempty,strfind(text{1},ellipsoid_joint{1})))];
    end
%     test_l = find(contains(text{1},ellipsoid_name{2}));%matlab2017
    test_l = find(~cellfun(@isempty,strfind(text{1},ellipsoid_name{2})));
    if ~isempty(test_l)
            true_ellipsoid_sign =  [true_ellipsoid_sign 2];
            true_ellipsoid_line =  [true_ellipsoid_line test_l];
            true_joint_line = [true_joint_line find(~cellfun(@isempty,strfind(text{1},ellipsoid_joint{2})))];
    end  
    nb_side_ellipsoid = length(true_ellipsoid_sign);
    
    true_acquisition_sign = [];
    if ~isempty(strfind(list_file_dynamic,'_R_'))%sum(contains(list_file_dynamic,'_R_'))>=1 %matlab2017
        true_acquisition_sign = [true_acquisition_sign 1];
    elseif ~isempty(strfind(list_file_dynamic,'_L_'))%sum(contains(list_file_dynamic,'_L'))>=1 %matlab2017
        true_acquisition_sign = [true_acquisition_sign 2];
    end
    nb_side_acquisition = length(true_acquisition_sign);
    
    var_ellipsoid_init = NaN(9,nb_side_ellipsoid); %line:or[x,y,z],pos[x,y,z],dim[x,y,z]; col:right,left;
    var_ellipsoid_optim = NaN(9,nb_side_ellipsoid); %line:or[x,y,z],pos[x,y,z],dim[x,y,z]; col:right,left;
    var_ellipsoid_line = NaN(4,nb_side_ellipsoid); %line:or,pos,dim; col:right,left;
    var_ellipsoid_line_in_joint = NaN(3,nb_side_ellipsoid);
    var_default_joint_config_line = NaN(3,nb_side_ellipsoid);
    for i_sign_ellips = true_ellipsoid_sign

    %0.5. Paramètres ellipsoid du modele generique
        %0.5.1. Orientation       
        iline = true_ellipsoid_line(i_sign_ellips);%wrap
        while cellfun(@isempty,strfind(text{1}(iline),'<xyz_body_rotation>'))%~contains(text{1}(iline),'<xyz_body_rotation>')    
            iline=iline+1;
        end           
        var_ellipsoid_line(1,true_ellipsoid_sign(i_sign_ellips)) = iline;
        
        iline = true_joint_line(i_sign_ellips); %joint
        while cellfun(@isempty,strfind(text{1}(iline),'<orientation_in_parent>'))%~contains(text{1}(iline),'<dimensions>')    
            iline=iline+1;
        end           
        var_ellipsoid_line_in_joint(1,true_ellipsoid_sign(i_sign_ellips)) = iline;  
        var_ellipsoid_temp = regexp(text{1}(iline),'-?\d+\.?\d*|-?\d*\.?\d+','match');
        var_ellipsoid_init(1:3,true_ellipsoid_sign(i_sign_ellips)) = str2double(var_ellipsoid_temp{1});
        
        jline = iline; while cellfun(@isempty,strfind(text{1}(jline),'scapula_abduction')), jline=jline+1; end
        kline = iline; while cellfun(@isempty,strfind(text{1}(kline),'scapula_elevation')), kline=kline+1; end
        lline = iline; while cellfun(@isempty,strfind(text{1}(lline),'scapula_upward_rot')), lline=lline+1; end
        var_default_joint_config_line (1:3,true_ellipsoid_sign(i_sign_ellips)) = [jline;kline;lline]+4;    
                    
        %0.3.2. Position
        iline = true_ellipsoid_line(i_sign_ellips);%wrap
        while cellfun(@isempty,strfind(text{1}(iline),'<translation>'))%~contains(text{1}(iline),'<translation>')    
            iline=iline+1;
        end           
        var_ellipsoid_line(2,true_ellipsoid_sign(i_sign_ellips)) = iline;
        
        iline = true_joint_line(i_sign_ellips); %joint
        while cellfun(@isempty,strfind(text{1}(iline),'<location_in_parent>'))%~contains(text{1}(iline),'<dimensions>')    
            iline=iline+1;
        end           
        var_ellipsoid_line_in_joint(2,true_ellipsoid_sign(i_sign_ellips)) = iline;    
        var_ellipsoid_temp = regexp(text{1}(iline),'-?\d+\.?\d*|-?\d*\.?\d+','match');
        var_ellipsoid_init(4:6,true_ellipsoid_sign(i_sign_ellips)) = str2double(var_ellipsoid_temp{1});
                        
        %0.3.3. Dimensions
        iline = true_ellipsoid_line(i_sign_ellips);%wrap
        while cellfun(@isempty,strfind(text{1}(iline),'<dimensions>'))%~contains   
            iline=iline+1;
        end           
        var_ellipsoid_line(3,true_ellipsoid_sign(i_sign_ellips)) = iline;%wrap
        
        iline = true_ellipsoid_line(i_sign_ellips); 
        while cellfun(@isempty,strfind(text{1}(iline),'<transform>'))%~contains  
            iline=iline+1;
        end           
        var_ellipsoid_line(4,true_ellipsoid_sign(i_sign_ellips)) = iline;         
        
        iline = true_joint_line(i_sign_ellips); %joint
        while cellfun(@isempty,strfind(text{1}(iline),'<thoracic_ellipsoid_radii_x_y_z>'))%~contains
            iline=iline+1;
        end           
        var_ellipsoid_line_in_joint(3,true_ellipsoid_sign(i_sign_ellips)) = iline;
        var_ellipsoid_temp = regexp(text{1}(iline),'-?\d+\.?\d*|-?\d*\.?\d+','match');
        var_ellipsoid_init(7:9,true_ellipsoid_sign(i_sign_ellips)) = str2double(var_ellipsoid_temp{1});

    end

%% 1. COORDONNEES DU CENTRE DE LA SCAPULA DANS THORAX
for i_sign_acq = true_acquisition_sign

%1.1. Boucle sur les acquisitions 
    coord_scapula = [];
    for i_acquisition = 1:length(list_file_dynamic)
    cur_acquisition = char(list_file_dynamic(i_acquisition));
    sign_idx = strfind(cur_acquisition,'_');
    sign_char = cur_acquisition(sign_idx(1)+1);
    
    if strcmp(sign_char,sign_char_en(i_sign_acq))

%1.2. Ouverture des données trc du mouvement
        data_trc   = lire_donnees_trc(fullfile(rep_cur_dynamic,cur_acquisition));
        data_trc.coord = data_trc.coord(1:5:end,:);%1/10 frame
        mark_coord = data_trc.coord;
        mark_names = data_trc.noms;
        nb_frame = size(mark_coord,1);
        
%1.3. Repère thorax à chaque instant dans global        
        TR0_TH = segment_matrix_from_trc(data_trc,'thorax');
   
%1.4. Marqueurs scaploc 
        num_AA  = find(strcmp(sprintf('AA%s',char(sign_char_fr(i_sign_acq))),mark_names));
        num_AI  = find(strcmp(sprintf('AI%s',char(sign_char_fr(i_sign_acq))),mark_names));
        num_TS  = find(strcmp(sprintf('TS%s',char(sign_char_fr(i_sign_acq))),mark_names));
        AA  = mark_coord(:,num_AA*3-2:num_AA*3);
        AI  = mark_coord(:,num_AI*3-2:num_AI*3);
        TS  = mark_coord(:,num_TS*3-2:num_TS*3);
        scap_center_in_global = (AA+AI+TS)./3;
        
%1.5 Coordonnées centre scaploc à chaque instant dans thorax
        scap_center_in_thorax = NaN(nb_frame,3);
        for iframe = 1:nb_frame 
            scap_center_in_thorax_temp = inv(TR0_TH(:,:,iframe))*[scap_center_in_global(iframe,:)' ;1];
             scap_center_in_thorax(iframe,:) = scap_center_in_thorax_temp(1:3);
%             TRTH_SL = TR0_TH(:,:,iframe)\TR0_SL(:,:,iframe);
%             scap_center_in_thorax(iframe,:) = TRTH_SL(1:3,4); %orientation dans thorax
        end
        
    coord_scapula = [coord_scapula; scap_center_in_thorax(~isnan(scap_center_in_thorax(:,1)),:)];
    
    end %if good side of acquisition   
    end % i_acq 

%% 2. OPTIMISATION ET RECALLAGE DE l'ELLIPSOIDE DANS LE MODELE
%2.1. Optimisation
    [var_ellipsoid_optim(:,i_sign_acq)] = optimize_ellipsoid_in_thorax(coord_scapula,var_ellipsoid_init(:,i_sign_acq));

    % verif: Plot generic vs. optimized ellipsoid
    %  figure, hold on 
    %  plot3(scap_center_in_thorax(:,3),scap_center_in_thorax(:,1),scap_center_in_thorax(:,2),'r*')
    %  plot_ellipsoid(var_ellipsoid_optim(:,i_sign_acq),100)
      
    var_ellipsoid_optim(1:3,i_sign_acq) = -var_ellipsoid_optim(1:3,i_sign_acq); %correction for indirect ellipsoid

% 2.2. Replacer la scapula dans le repère de l'éllipsoide
    %2.2.1. Coordonnees dans le static
    mark_coord = st_trc.coord(1,:);
    mark_names = st_trc.noms;
    nb_frame = size(mark_coord,1);
         
    %2.2.2. Marqueurs scaploc 
    num_AA  = find(strcmp(sprintf('AA%s',char(sign_char_fr(i_sign_acq))),mark_names));
    num_AI  = find(strcmp(sprintf('AI%s',char(sign_char_fr(i_sign_acq))),mark_names));
    num_TS  = find(strcmp(sprintf('TS%s',char(sign_char_fr(i_sign_acq))),mark_names));
    AA  = mark_coord(:,num_AA*3-2:num_AA*3);
    AI  = mark_coord(:,num_AI*3-2:num_AI*3);
    TS  = mark_coord(:,num_TS*3-2:num_TS*3);
    scap_center_in_global = (AA+AI+TS)./3;
    
    %2.2.3.  Repère scaploc dans global
    R0_SL = mark_2_mat('scapula',scap_center_in_global,AA,TS,AI,sign(i_sign_acq)); %(origine centre scaploc)
   
    %2.2.4.  Repère thorax dans global
   R0_TH = segment_matrix_from_trc(st_trc,'thorax');
   R0_TH = R0_TH(:,:,1);

    %2.2.5. Repère ellipsoid dans thorax
   RTH_ellips = matrice_homogene(var_ellipsoid_optim(1:3,i_sign_acq),var_ellipsoid_optim(4:6,i_sign_acq));
   
    %2.2.6. Repère scapula dans ellipsoid
    Rellips_SL = RTH_ellips\R0_TH\R0_SL;
    theta_2 = asin(Rellips_SL(2,4)/var_ellipsoid_optim(8,i_sign_acq));
    theta_1 = atan(Rellips_SL(1,4)/Rellips_SL(3,4) * var_ellipsoid_optim(9,i_sign_acq)/var_ellipsoid_optim(7,i_sign_acq));
    theta_3 = asin(Rellips_SL(2,2)/cos(theta_1));
    static_location_in_ellipsoid = [theta_1 theta_2 theta_3];
%     static_orientation_in_ellipsoid = axemobile_yxz(Rellips_SL(1:3,1:3))*pi/180;%elev,abd,upwd
%     static_location_in_ellipsoid = Rellips_SL(1:3,4);

%2.3. Correction de la position du thorax marqueurs par rapport au thorax modele
    %2.3.1 Matrice du thorax dans le trc
    R0_thorax_mark = segment_matrix_from_trc(st_trc,'thorax');

    %2.3.2 Matrice du thorax dans le mot
    R0_thorax_model = segment_matrix_from_mot(st_model,st_mot,'thorax');

    %2.3.3. Correction de l'éllipsoide
    [R1,R2,R3] = Rotations2Matrix_xyz(var_ellipsoid_optim(1,i_sign_acq),var_ellipsoid_optim(2,i_sign_acq),var_ellipsoid_optim(3,i_sign_acq));
    Rthorax_2_ellips_init = [R1*R2*R3 var_ellipsoid_optim(4:6,i_sign_acq);0 0 0 1];
    Rthorax_2_ellips_corr = R0_thorax_model(:,:,1)\R0_thorax_mark(:,:,1)*Rthorax_2_ellips_init;
%     Rthorax_2_ellips_corr = R0_thorax_mark(:,:,1)\R0_thorax_model(:,:,1)*[0 0 -1 0;0 1 0 0;1 0 0 0;0 0 0 1]*Rthorax_2_ellips_init;
    var_ellipsoid_optim(4:6,i_sign_acq) = Rthorax_2_ellips_corr(1:3,4); %position
    var_ellipsoid_optim(1:3,i_sign_acq) = axemobile_xyz(Rthorax_2_ellips_corr(1:3,1:3))*pi/180; %orientation
%     var_ellipsoid_optim(1:3,i_sign_acq) = axemobile_zyx(Rthorax_2_ellips_corr(1:3,1:3)); %orientation
%     var_ellipsoid_optim(1,i_sign_acq) = -var_ellipsoid_optim(1,i_sign_acq); % corr axis x
%     %     var_ellipsoid_optim(3,i_sign_acq) = var_ellipsoid_optim(3,i_sign_acq)+pi/2;
%     var_ellipsoid_optim(4,i_sign_acq) = var_ellipsoid_optim(6,i_sign_acq); % corr axis x
%     var_ellipsoid_optim(6,i_sign_acq) = -var_ellipsoid_optim(4,i_sign_acq); % corr axis z

%% 3. Reintegrer les parametres optimaux dans le modele
%3.1. Dans le text
%3.1.1. wrapping
text{1}(var_ellipsoid_line(1,i_sign_acq)) = cellstr(sprintf('<xyz_body_rotation> %f %f %f</xyz_body_rotation>',var_ellipsoid_optim(1,i_sign_acq),var_ellipsoid_optim(2,i_sign_acq),var_ellipsoid_optim(3,i_sign_acq)));        
text{1}(var_ellipsoid_line(2,i_sign_acq)) = cellstr(sprintf('<translation> %f %f %f</translation>',var_ellipsoid_optim(4,i_sign_acq),var_ellipsoid_optim(5,i_sign_acq),var_ellipsoid_optim(6,i_sign_acq)));        
text{1}(var_ellipsoid_line(3,i_sign_acq)) = cellstr(sprintf('<dimensions> %f %f %f</dimensions>',var_ellipsoid_optim(7,i_sign_acq),var_ellipsoid_optim(8,i_sign_acq),var_ellipsoid_optim(9,i_sign_acq)));        
text{1}(var_ellipsoid_line(4,i_sign_acq)) = cellstr(sprintf('<transform> %f %f %f %f %f %f</transform>',var_ellipsoid_optim(1,i_sign_acq),var_ellipsoid_optim(2,i_sign_acq),var_ellipsoid_optim(3,i_sign_acq),var_ellipsoid_optim(4,i_sign_acq),var_ellipsoid_optim(5,i_sign_acq),var_ellipsoid_optim(6,i_sign_acq)));        
%3.1.2. joint
% text{1}(var_ellipsoid_line_in_joint(1,i_sign_acq)) = cellstr(sprintf('<orientation> %f %f %f</orientation>',orientation_in_ellipsoid(1),orientation_in_ellipsoid(2),orientation_in_ellipsoid(3)));        
% text{1}(var_ellipsoid_line_in_joint(2,i_sign_acq)) = cellstr(sprintf('<location> %f %f %f</location>',location_in_ellipsoid(1),location_in_ellipsoid(2),location_in_ellipsoid(3)));        
text{1}(var_ellipsoid_line_in_joint(1,i_sign_acq)) = cellstr(sprintf('<orientation_in_parent> %f %f %f</orientation_in_parent>',var_ellipsoid_optim(1,i_sign_acq),var_ellipsoid_optim(2,i_sign_acq),var_ellipsoid_optim(3,i_sign_acq)));        
text{1}(var_ellipsoid_line_in_joint(2,i_sign_acq)) = cellstr(sprintf('<location_in_parent> %f %f %f</location_in_parent>',var_ellipsoid_optim(4,i_sign_acq),var_ellipsoid_optim(5,i_sign_acq),var_ellipsoid_optim(6,i_sign_acq)));        
text{1}(var_ellipsoid_line_in_joint(3,i_sign_acq)) = cellstr(sprintf('<thoracic_ellipsoid_radii_x_y_z> %f %f %f</thoracic_ellipsoid_radii_x_y_z>',var_ellipsoid_optim(7,i_sign_acq),var_ellipsoid_optim(8,i_sign_acq),var_ellipsoid_optim(9,i_sign_acq)));        
%3.1.3. default position of scapula in ellipsoid
% text{1}(var_default_joint_config_line(1,i_sign_acq)) = cellstr(sprintf('<default_value> %f</default_value>',static_orientation_in_ellipsoid(1)));        
% text{1}(var_default_joint_config_line(2,i_sign_acq)) = cellstr(sprintf('<default_value> %f</default_value>',static_orientation_in_ellipsoid(2)));        
% text{1}(var_default_joint_config_line(3,i_sign_acq)) = cellstr(sprintf('<default_value> %f</default_value>',static_orientation_in_ellipsoid(3)));        
% text{1}(var_default_joint_config_line(1,i_sign_acq)+4) = cellstr(sprintf('<range> %f %f</range>',static_orientation_in_ellipsoid(1)-pi/4,static_orientation_in_ellipsoid(1)+pi/4));        
% text{1}(var_default_joint_config_line(2,i_sign_acq)+4) = cellstr(sprintf('<range> %f %f</range>',static_orientation_in_ellipsoid(2)-pi/4,static_orientation_in_ellipsoid(2)+pi/4));        
% text{1}(var_default_joint_config_line(3,i_sign_acq)+4) = cellstr(sprintf('<range> %f %f</range>',static_orientation_in_ellipsoid(3)-pi/4,static_orientation_in_ellipsoid(3)+pi/4));        
text{1}(var_default_joint_config_line(1,i_sign_acq)) = cellstr(sprintf('<default_value> %f</default_value>',static_location_in_ellipsoid(1)));        
text{1}(var_default_joint_config_line(2,i_sign_acq)) = cellstr(sprintf('<default_value> %f</default_value>',static_location_in_ellipsoid(2)));        
text{1}(var_default_joint_config_line(3,i_sign_acq)) = cellstr(sprintf('<default_value> %f</default_value>',static_location_in_ellipsoid(3)));        
text{1}(var_default_joint_config_line(1,i_sign_acq)+4) = cellstr(sprintf('<range> %f %f</range>',static_location_in_ellipsoid(1)-pi/4,static_location_in_ellipsoid(1)+pi/4));        
text{1}(var_default_joint_config_line(2,i_sign_acq)+4) = cellstr(sprintf('<range> %f %f</range>',static_location_in_ellipsoid(2)-pi/4,static_location_in_ellipsoid(2)+pi/4));        
text{1}(var_default_joint_config_line(3,i_sign_acq)+4) = cellstr(sprintf('<range> %f %f</range>',static_location_in_ellipsoid(3)-pi/4,static_location_in_ellipsoid(3)+pi/4));        

%3.2. Assurer la symetrie si l'on a les donnees d'un seul cote
if nb_side_acquisition<nb_side_ellipsoid
    i_sign_opp = (-(i_sign_acq*2-3)+3)/2;
    var_ellipsoid_optim(:,i_sign_opp) = var_ellipsoid_optim(:,i_sign_acq);
    var_ellipsoid_optim([1:2 6],i_sign_opp) = -var_ellipsoid_optim([1:2 6],i_sign_acq);%inverse les rotations de x,y et la translation z
    %wrapping
    text{1}(var_ellipsoid_line(1,i_sign_opp)) = cellstr(sprintf('<xyz_body_rotation> %f %f %f </xyz_body_rotation>',var_ellipsoid_optim(1,i_sign_opp),var_ellipsoid_optim(2,i_sign_opp),var_ellipsoid_optim(3,i_sign_opp)));        
    text{1}(var_ellipsoid_line(2,i_sign_opp)) = cellstr(sprintf('<translation> %f %f %f </translation>',var_ellipsoid_optim(4,i_sign_opp),var_ellipsoid_optim(5,i_sign_opp),var_ellipsoid_optim(6,i_sign_opp)));        
    text{1}(var_ellipsoid_line(3,i_sign_opp)) = cellstr(sprintf('<dimensions> %f %f %f </dimensions>',var_ellipsoid_optim(7,i_sign_opp),var_ellipsoid_optim(8,i_sign_opp),var_ellipsoid_optim(9,i_sign_opp)));            
    %joint
    text{1}(var_ellipsoid_line_in_joint(1,i_sign_opp)) = cellstr(sprintf('<orientation_in_parent> %f %f %f </orientation_in_parent>',var_ellipsoid_optim(1,i_sign_opp),var_ellipsoid_optim(2,i_sign_opp),var_ellipsoid_optim(3,i_sign_opp)));        
    text{1}(var_ellipsoid_line_in_joint(2,i_sign_opp)) = cellstr(sprintf('<location_in_parent> %f %f %f </location_in_parent>',var_ellipsoid_optim(4,i_sign_opp),var_ellipsoid_optim(5,i_sign_opp),var_ellipsoid_optim(6,i_sign_opp)));        
    text{1}(var_ellipsoid_line_in_joint(3,i_sign_opp)) = cellstr(sprintf('<thoracic_ellipsoid_radii_x_y_z> %f %f %f </thoracic_ellipsoid_radii_x_y_z>',var_ellipsoid_optim(7,i_sign_opp),var_ellipsoid_optim(8,i_sign_opp),var_ellipsoid_optim(9,i_sign_opp)));        
    %default position
    text{1}(var_default_joint_config_line(1,i_sign_opp)) = cellstr(sprintf('<default_value> %f</default_value>',-static_location_in_ellipsoid(1)));        
    text{1}(var_default_joint_config_line(2,i_sign_opp)) = cellstr(sprintf('<default_value> %f</default_value>',-static_location_in_ellipsoid(2)));        
    text{1}(var_default_joint_config_line(3,i_sign_opp)) = cellstr(sprintf('<default_value> %f</default_value>',static_location_in_ellipsoid(3)));        
    text{1}(var_default_joint_config_line(1,i_sign_opp)+4) = cellstr(sprintf('<range> %f %f</range>',-static_location_in_ellipsoid(1)-pi/4,-static_location_in_ellipsoid(1)+pi/4));        
    text{1}(var_default_joint_config_line(2,i_sign_opp)+4) = cellstr(sprintf('<range> %f %f</range>',-static_location_in_ellipsoid(2)-pi/4,-static_location_in_ellipsoid(2)+pi/4));        
    text{1}(var_default_joint_config_line(3,i_sign_opp)+4) = cellstr(sprintf('<range> %f %f</range>',static_location_in_ellipsoid(3)-pi/4,static_location_in_ellipsoid(3)+pi/4));        
end

end % i_sign_acq       

% 3.3 SAVE : Sauvegarder le nouveau modele
file_model_ellipsoid = [cur_sujet '_' cur_activity '_model_ellipsoid.osim'];
path_model_ellipsoid = fullfile(rep_global,cur_sujet,'modele',file_model_ellipsoid);
% save([path_model_ellipsoid(1:end-5) '.mat'],'struct_OSIM');

fid = fopen(char(path_model_ellipsoid), 'w');
for iline = 1:nbline, fprintf(fid, '%s\n', char(text{1}{iline})); end
fclose(fid);

end %if ScapulothoracicEllipsoid

end