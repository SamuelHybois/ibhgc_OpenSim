function [TRTH_CL]=scapula_cluster_ik(repertoire_activites,cur_activity,cur_acquisition)

sign_idx=strfind(cur_acquisition,'_');
sign_char=cur_acquisition(sign_idx(1)+1);
if ~isempty(strfind(sign_char,'L')), sign=-1; sign_char='G';
else sign=1; sign_char='D';
end

cur_acquisition = fullfile(repertoire_activites,cur_activity,cur_acquisition);
data_trc = lire_donnees_trc(cur_acquisition); 
mark_names = data_trc.noms;
mark_coord = data_trc.coord;
nb_frame = size(mark_coord,1);
fig=figure(1);hold on, plot_mark(mark_names,mark_coord(1,:),[0 0 1],fig)%blue

%% Thorax
% Markers names
num_C7=find(strcmp('C7',mark_names));
num_MAN=find(strcmp('MAN',mark_names));
num_XYP=find(strcmp('XYP',mark_names));
num_T8=find(strcmp('T8',mark_names));

% Markers coordinates
C7 = mark_coord(:,num_C7*3-2:num_C7*3);
MAN = mark_coord(:,num_MAN*3-2:num_MAN*3);
XYP = mark_coord(:,num_XYP*3-2:num_XYP*3);
T8 = mark_coord(:,num_T8*3-2:num_T8*3);

% Thorax in global
TR0_TH = mark_2_mat('thorax',MAN,XYP,C7,T8,1);

%% Cluster
% Markers names
num_MTAC_L=find(strcmp(['MTAC' sign_char 'L'],mark_names));
num_MTAC_M=find(strcmp(['MTAC' sign_char 'M'],mark_names));
num_MTAC_B=find(strcmp(['MTAC' sign_char 'B'],mark_names));
num_AC=find(strcmp(['AC' sign_char],mark_names));

% Markers coordinates
MTAC_L = mark_coord(:,num_MTAC_L*3-2:num_MTAC_L*3);
MTAC_M = mark_coord(:,num_MTAC_M*3-2:num_MTAC_M*3);
MTAC_B = mark_coord(:,num_MTAC_B*3-2:num_MTAC_B*3);
AC = mark_coord(:,num_AC*3-2:num_AC*3);

% Cluster in global 
TR0_CL=mark_2_mat('scapula',AC,MTAC_L,MTAC_M,MTAC_B,sign);
% TR0_CL=mark_2_mat('scapula_AC',AC,MTAC_L,MTAC_M,MTAC_B,sign);

%% Cluster in Thorax 
for iframe=1:nb_frame
    TRTH_CL(:,:,iframe)=inv(TR0_TH(:,:,iframe))*TR0_CL(:,:,iframe);
end%iframe

end