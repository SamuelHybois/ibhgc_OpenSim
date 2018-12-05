function [TRTH_SL,TRSL_SC,sign]=scapula_locator_ik(rep_sujet,cur_activity,cur_acquisition,cur_static,st_model)


%% Ouverture des donnees

% Ouverture des données de référence cluster et scaploc (calib statique)
sign_idx=strfind(cur_acquisition,'_');
sign_char=cur_acquisition(sign_idx(1)+1);
if ~isempty(strfind(sign_char,'L')), sign=-1; sign_char_fr='G';
else sign=1; sign_char_fr='D';
end

data_trc_static = lire_donnees_trc(cur_static);
frame_recalage = 1;
mark_names_static = data_trc_static.noms;
mark_coord_static = data_trc_static.coord(frame_recalage,:); 
% plot_mark(mark_names_static,mark_coord_static,[1 0 0],fig)

% Ouverture des données scaploc du mouvement
data_trc   = lire_donnees_trc(fullfile(rep_sujet,cur_activity,cur_acquisition));
mark_names = data_trc.noms;
mark_coord = data_trc.coord;
nb_frame   = size(mark_coord,1);
% plot_mark(mark_names,mark_coord,[0 1 0],fig)

%% Construction des matrices de passage de Référence

% Marqueurs thorax static
%Pour alleger:  RO_Rseg = segment_matrix_from_trc(data_static_trc,seg);
num_C7_s  = find(strcmp('C7',mark_names_static));
num_MAN_s = find(strcmp('MAN',mark_names_static));
num_XYP_s = find(strcmp('XYP',mark_names_static));
num_T8_s  = find(strcmp('T8',mark_names_static));
C7_s  = mark_coord_static(num_C7_s*3-2:num_C7_s*3);
MAN_s = mark_coord_static(num_MAN_s*3-2:num_MAN_s*3);
XYP_s = mark_coord_static(num_XYP_s*3-2:num_XYP_s*3);
T8_s = mark_coord_static(num_T8_s*3-2:num_T8_s*3);

% Repère thorax static dans global 
% TR0_TH_s = mark_2_mat('thorax',MAN_s,XYP_s,C7_s);

% Marqueurs cluster static
num_MTAC_L_s = find(strcmp(['MTAC' sign_char_fr 'L'],mark_names_static));
num_MTAC_M_s = find(strcmp(['MTAC' sign_char_fr 'M'],mark_names_static));
num_MTAC_B_s = find(strcmp(['MTAC' sign_char_fr 'B'],mark_names_static));
num_AC_s    = find(strcmp(['AC' sign_char_fr],mark_names_static));
MTAC_L_s = mark_coord_static(num_MTAC_L_s*3-2:num_MTAC_L_s*3);
MTAC_M_s = mark_coord_static(num_MTAC_M_s*3-2:num_MTAC_M_s*3);
MTAC_B_s = mark_coord_static(num_MTAC_B_s*3-2:num_MTAC_B_s*3);
AC_s    = mark_coord_static(num_AC_s*3-2:num_AC_s*3);

% Marqueurs scaploc static
num_SCLL_s  = find(strcmp('SCLL',mark_names_static));
num_SCLM_s  = find(strcmp('SCLM',mark_names_static));
num_SCLB_s  = find(strcmp('SCLB',mark_names_static));
num_SCLHM_s = find(strcmp('SCLHM',mark_names_static));
num_SCLHL_s = find(strcmp('SCLHL',mark_names_static));
SCLL_s  = mark_coord_static(num_SCLL_s*3-2:num_SCLL_s*3);
SCLM_s  = mark_coord_static(num_SCLM_s*3-2:num_SCLM_s*3);
SCLB_s  = mark_coord_static(num_SCLB_s*3-2:num_SCLB_s*3);
SCLHM_s = mark_coord_static(num_SCLHM_s*3-2:num_SCLHM_s*3);
SCLHL_s = mark_coord_static(num_SCLHL_s*3-2:num_SCLHL_s*3);

% % Recalage vertical scaploc static
% u1 = (SCLHM_s - SCLB_s)./norm(SCLHM_s - SCLB_s);
% u2 = (SCLHL_s - SCLB_s)./norm(SCLHL_s - SCLB_s);
% normale_plan_ScapLoc_s = sign * cross(u1,u2) ./ norm(cross(u1,u2));
% SCLL_s = SCLL_s + dist_SL.*normale_plan_ScapLoc_s ;
% SCLM_s = SCLM_s + dist_SL.*normale_plan_ScapLoc_s ;
% SCLB_s = SCLB_s + dist_SL.*normale_plan_ScapLoc_s ;

% Repère scaploc à cluster static
TR0_SC_s    = mark_2_mat('scapula',AC_s,MTAC_L_s,MTAC_M_s,MTAC_B_s,sign); %cluster dans global
TR0_SL_s    = mark_2_mat('scapula',SCLL_s,SCLL_s,SCLM_s,SCLB_s,sign); %scaploc dans global (origine SCLL)
% TR0_SL_s    = mark_2_mat('scapula',AC_s,SCLL_s,SCLM_s,SCLB_s,sign); %scaploc dans global (origine AC)
TRSL_SC     = TR0_SL_s\TR0_SC_s;

% Repère scaploc à thorax static
% Via OS
% TR0_SL  = inv(TR0_TH)*TR0_SL;                               %scaploc dans thorax
% TR0_OS  = scapula_os_ik(repertoire_activites,folder_static,file_static,st_model); %scapOS dans thorax
% TRSL_TH = inv(TR0_SL)*TR0_OS(:,:,1);                       %scaploc->thorax->scapOS
% Sans OS
%  TRSL_TH = inv(TR0_SL)*TR0_TH(:,:,1);                      

%% Construction des matrices du scaploc au cours du mouvement

% Marqueurs thorax
num_C7  = find(strcmp('C7',mark_names));
num_MAN = find(strcmp('MAN',mark_names));
num_XYP = find(strcmp('XYP',mark_names));
num_T8  = find(strcmp('T8',mark_names));
C7  = mark_coord(:,num_C7*3-2:num_C7*3);
MAN = mark_coord(:,num_MAN*3-2:num_MAN*3);
XYP = mark_coord(:,num_XYP*3-2:num_XYP*3);
T8  = mark_coord(:,num_T8*3-2:num_T8*3);

% Repère thorax dans global à chaque instant
TR0_TH = mark_2_mat('thorax',MAN,XYP,C7,T8);

% Marqueurs cluster 
num_MTAC_L = find(strcmp(['MTAC' sign_char_fr 'L'],mark_names));
num_MTAC_M = find(strcmp(['MTAC' sign_char_fr 'M'],mark_names));
num_MTAC_B = find(strcmp(['MTAC' sign_char_fr 'B'],mark_names));
num_AC    = find(strcmp(['AC' sign_char_fr],mark_names));
MTAC_L = mark_coord(:,num_MTAC_L*3-2:num_MTAC_L*3);
MTAC_M = mark_coord(:,num_MTAC_M*3-2:num_MTAC_M*3);
MTAC_B = mark_coord(:,num_MTAC_B*3-2:num_MTAC_B*3);
AC     = mark_coord(:,num_AC*3-2:num_AC*3);

% Repère global à cluster (pour comparaison)
% TR0_SC = mark_2_mat('scapula',AC,MTAC_L,MTAC_M,MTAC_B,sign);

% Marqueurs scaploc 
num_SCLL  = find(strcmp('SCLL',mark_names));
num_SCLM  = find(strcmp('SCLM',mark_names));
num_SCLB  = find(strcmp('SCLB',mark_names));
num_SCLHM = find(strcmp('SCLHM',mark_names));
num_SCLHL = find(strcmp('SCLHL',mark_names));
SCLL  = mark_coord(:,num_SCLL*3-2:num_SCLL*3);
SCLM  = mark_coord(:,num_SCLM*3-2:num_SCLM*3);
SCLB  = mark_coord(:,num_SCLB*3-2:num_SCLB*3);
SCLHM = mark_coord(:,num_SCLHM*3-2:num_SCLHM*3);
SCLHL = mark_coord(:,num_SCLHL*3-2:num_SCLHL*3);

% % Recalage vertical scaploc
% u1 = (SCLHM-SCLB) ./ repmat(sqrt(sum((SCLHM-SCLB).*(SCLHM-SCLB),2)),1,3);
% u2 = (SCLHL-SCLB) ./ repmat(sqrt(sum((SCLHL-SCLB).*(SCLHL-SCLB),2)),1,3);
% normale_plan_ScapLoc = sign * cross(u1,u2) ./ repmat(sqrt(sum(cross(u1,u2).*cross(u1,u2),2)),1,3);
% SCLL = SCLL + dist_SL.*normale_plan_ScapLoc ;
% SCLM = SCLM + dist_SL.*normale_plan_ScapLoc ;
% SCLB = SCLB + dist_SL.*normale_plan_ScapLoc ;

% Repère scaploc à chaque instant dans global
TR0_SL = mark_2_mat('scapula',SCLL,SCLL,SCLM,SCLB,sign); %scaploc R0 (origine SCLL)
% TR0_SL = mark_2_mat('scapula',AC,SCLL,SCLM,SCLB,sign); %scaploc R0 (origine AC)

% Repère scapula à partir de scaploc à chaque instant dans thorax
TRTH_SL=zeros(4,4,nb_frame);
for iframe = 1:nb_frame 
    TRTH_SL(:,:,iframe) = TR0_TH(:,:,iframe)\TR0_SL(:,:,iframe)*TRSL_SC; %orientation dans thorax
end
    
%Vérification visuelle
fig=figure(1); 
true_mark_names = {'C7' 'MAN' 'XYP' 'T8' 'SCLM' 'SCLB' 'SCLL' 'SCLHM' 'SCLHL' 'MTAC_L' 'MTAC_M' 'MTAC_B' 'AC'};
true_mark_coord = NaN(size(mark_coord,1),length(true_mark_names)*3);
for imark=1:length(true_mark_names)
    if ~isempty(eval(['num_' char(true_mark_names(imark))])), 
        true_mark_num = eval(['num_' char(true_mark_names(imark))]); 
        true_mark_coord(:,imark*3-2:imark*3)= mark_coord(:,true_mark_num*3-2:true_mark_num*3);
    end
end
true_mark_coord_static = NaN(size(mark_coord_static,1),length(true_mark_names)*3);
for imark=1:length(true_mark_names)
    if ~isempty(eval(['num_' char(true_mark_names(imark)) '_s'])), 
        true_mark_num_static = eval(['num_' char(true_mark_names(imark)) '_s']); 
        true_mark_coord_static(:,imark*3-2:imark*3)= mark_coord_static(1,true_mark_num_static*3-2:true_mark_num_static*3);
    end
end

corrected_cl_mark_coord = NaN(nb_frame,size(true_mark_coord,2));
for iframe = 1%:nb_frame     
    for imark=10:13
       imark_coord_in_SC = TR0_SC_s\[true_mark_coord_static(1,imark*3-2:imark*3) 1]';%exprimé dans cluster prédit
       corrected_cl_mark_coord_temp = TR0_SL(:,:,iframe)*TRSL_SC*imark_coord_in_SC;
%        imark_coord_in_SL = TR0_SL_s\[true_mark_coord_static(1,imark*3-2:imark*3) 1]';%exprimé dans la scapula
%        corrected_cl_mark_coord_temp = TR0_SL(:,:,iframe)*imark_coord_in_SL;
       corrected_cl_mark_coord (iframe,imark*3-2:imark*3) = corrected_cl_mark_coord_temp(1:3);
    end
%     plot_mark(true_mark_names,true_mark_coord(iframe,:),[0 0 1],fig)%blue
    plot_mark(true_mark_names(10:13),corrected_cl_mark_coord(iframe,28:39),[0 1 0],fig)%green
    norm2(reshape(true_mark_coord(iframe,31:39)-true_mark_coord(iframe,28:36),3,3)');
    norm2(reshape(corrected_cl_mark_coord(iframe,31:39)-corrected_cl_mark_coord(iframe,28:36),3,3)');
end
hold off

end% function