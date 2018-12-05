function st_marqueurs_cine_out = symetrical_scaploc_mark(st_marqueurs_cine_in,side)


% Definition du cote oppose
if strcmp(side,'D'), side_sym = 'G';
else                 side_sym = 'D';
end

% Repere thorax dans global a chaque instant
TR = mark_2_mat('thorax',st_marqueurs_cine_in.MAN, st_marqueurs_cine_in.XYP, st_marqueurs_cine_in.C7, st_marqueurs_cine_in.T8);

% Coordonnees marqueurs scapula presente dans global
AA = eval(['st_marqueurs_cine_in.AA' side]);
AI = eval(['st_marqueurs_cine_in.AI' side]);
TS = eval(['st_marqueurs_cine_in.TS' side]);
SCLHM = eval(['st_marqueurs_cine_in.SCLHM' side]);
SCLHL = eval(['st_marqueurs_cine_in.SCLHL' side]);

nb_frame = size(AA,1);
% Coordonnees marqueurs scapula presente dans thorax
AA_th = NaN(4,nb_frame);
AI_th = NaN(4,nb_frame);
TS_th = NaN(4,nb_frame);
SCLHM_th = NaN(4,nb_frame);
SCLHL_th = NaN(4,nb_frame);
for iframe = 1:nb_frame
    AA_th(:,iframe) = TR(:,:,iframe)\[AA(iframe,:)';1];
    AI_th(:,iframe) = TR(:,:,iframe)\[AI(iframe,:)';1];
    TS_th(:,iframe) = TR(:,:,iframe)\[TS(iframe,:)';1];
    SCLHM_th(:,iframe) = TR(:,:,iframe)\[SCLHM(iframe,:)';1];
    SCLHL_th(:,iframe) = TR(:,:,iframe)\[SCLHL(iframe,:)';1];    
end

% Coordonnees marqueurs scapula absente dans thorax
AA_abs = [AA_th(1,:);AA_th(2,:);-AA_th(3,:);ones(1,nb_frame)];
AI_abs = [AI_th(1,:);AI_th(2,:);-AI_th(3,:);ones(1,nb_frame)];
TS_abs = [TS_th(1,:);TS_th(2,:);-TS_th(3,:);ones(1,nb_frame)];
SCLHM_abs = [SCLHM_th(1,:);SCLHM_th(2,:);-SCLHM_th(3,:);ones(1,nb_frame)];
SCLHL_abs = [SCLHL_th(1,:);SCLHL_th(2,:);-SCLHL_th(3,:);ones(1,nb_frame)];

% Coordonnees marqueurs scapula absente dans global
AA_glo = NaN(4,nb_frame);
AI_glo = NaN(4,nb_frame);
TS_glo = NaN(4,nb_frame);
SCLHM_glo = NaN(4,nb_frame);
SCLHL_glo = NaN(4,nb_frame);
for iframe = 1:nb_frame
    AA_glo(:,iframe) = TR(:,:,iframe)*AA_abs(:,iframe);
    AI_glo(:,iframe) = TR(:,:,iframe)*AI_abs(:,iframe);
    TS_glo(:,iframe) = TR(:,:,iframe)*TS_abs(:,iframe);
    SCLHM_glo(:,iframe) = TR(:,:,iframe)*SCLHM_abs(:,iframe);
    SCLHL_glo(:,iframe) = TR(:,:,iframe)*SCLHL_abs(:,iframe);    
end

% Coordonnees marqueurs scapula absente dans structure
st_marqueurs_cine_out = st_marqueurs_cine_in;
eval(sprintf('st_marqueurs_cine_out.AA%s = AA_glo(1:3,:)'';', side_sym));
eval(sprintf('st_marqueurs_cine_out.AI%s = AI_glo(1:3,:)'';', side_sym));
eval(sprintf('st_marqueurs_cine_out.TS%s = TS_glo(1:3,:)'';', side_sym));
eval(sprintf('st_marqueurs_cine_out.SCLHM%s = SCLHM_glo(1:3,:)'';', side_sym));
eval(sprintf('st_marqueurs_cine_out.SCLHL%s = SCLHL_glo(1:3,:)'';', side_sym));

end%function