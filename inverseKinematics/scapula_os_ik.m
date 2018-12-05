function [TRscap_OS]=scapula_os_ik(repertoire_activites,cur_activity,cur_acquisition,st_model)   
% Fonction pour extraire la matrice de passage du thorax à la scapula
% obtenue par la cinématique inverse d'OpenSim

[~,sign_char_en,sign_char_fr] = side_of_acquisition(cur_acquisition);
    
%% A partir du fichier .STO
sto_path = fullfile(repertoire_activites,cur_activity,[cur_acquisition(1:end-4) '_ANALYZE']);
if ~exist(sto_path,'dir'), display('Static file has to be ANALYSED first'), end

[~,sto_file] =  PathContent_Type(sto_path,'pos_global');
sto = fullfile(sto_path,sto_file);
[dof_data,dof_names,st_data] = lire_donnees_sto(char(sto));
nb_frame = size(dof_data,1);

% Matrix in OS
TR0_TH = sto_2_RTmat('thorax',dof_data,dof_names,st_model); 
TR0_SC = sto_2_RTmat(['scapula_' sign_char_en],dof_data,dof_names,st_model);

% %% A partir du fichier IK.mot
% % Ouverture des coordonnées généralisées
% mot_path = fullfile(repertoire_activites,cur_activity,[cur_acquisition(1:end-4) '_ik_lisse.mot']);
% [~,~,st_data]  = lire_donnees_mot(mot_path,'radians');
% 
% % Reconstruction des coordonnées de marqueurs
% 
% coord_recons = cinematiqueDirecte(st_model,st_data);
% TR0_TH = mark_2_mat('thorax',coord_recons.MAN,coord_recons.XYP,coord_recons.C7);
% TR0_SC = mark_2_mat('scapula',eval(['coord_recons.AC' sign_char_fr]),...
%                             eval(['coord_recons.MTAC' sign_char_fr 'L']),...
%                             eval(['coord_recons.MTAC' sign_char_fr 'M']),...
%                             eval(['coord_recons.MTAC' sign_char_fr 'B']),sign);
% nb_frame = size(TR0_TH,3);
% 
% % [~,cell_mrk] = extract_st_mrk_from_model(st_model);
% % % Matrix thorax out OS
% % num_MAN = (strcmp(cell_mrk(:,1),'thorax')+strcmp(cell_mrk(:,2),'MAN'))==2;
% % num_XYP = (strcmp(cell_mrk(:,1),'thorax')+strcmp(cell_mrk(:,2),'XYP'))==2;
% % num_C7  = (strcmp(cell_mrk(:,1),'thorax')+strcmp(cell_mrk(:,2),'C7'))==2;
% % loc_MAN = cell_mrk{num_MAN,3};
% % loc_XYP = cell_mrk{num_XYP,3};
% % loc_C7  = cell_mrk{num_C7,3};
% % 
% % TH_OS_out = mark_2_mat('thorax',loc_MAN,loc_XYP,loc_C7);
% % 
% % % Matrix scapula out OS
% % num_ACD    = (strcmp(cell_mrk(:,1),'scapula_r')+ strcmp(cell_mrk(:,2),'ACD'))==2;
% % num_MTACDL = (strcmp(cell_mrk(:,1),'scapula_r')+strcmp(cell_mrk(:,2),'MTACDL'))==2;
% % num_MTACDM = (strcmp(cell_mrk(:,1),'scapula_r')+strcmp(cell_mrk(:,2),'MTACDM'))==2;
% % num_MTACDB = (strcmp(cell_mrk(:,1),'scapula_r')+strcmp(cell_mrk(:,2),'MTACDB'))==2;
% % loc_ACD    = cell_mrk{num_ACD,3};
% % loc_MTACDL = cell_mrk{num_MTACDL,3};
% % loc_MTACDM = cell_mrk{num_MTACDM,3};
% % loc_MTACDB = cell_mrk{num_MTACDB,3};
% % 
% % SC_OS_out=mark_2_mat('scapula_AC',loc_ACD,loc_MTACDL,loc_MTACDM,loc_MTACDB);

% Matrix scapula in thorax from OS
TRscap_OS(4,4,nb_frame)=0;
for iframe=1:nb_frame   
    TRscap_OS(:,:,iframe) = TR0_TH(:,:,iframe)\TR0_SC(:,:,iframe);                     
end%iframe

% Vérification
% Récupération des coordonnées locales des marqueurs
nb_mark = length(st_model.Model.MarkerSet.objects.Marker);
true_mark_names = {'MAN','XYP','C7','T8',... %thorax
                  ['MTAC' sign_char_fr 'L'],['MTAC' sign_char_fr 'M'],['MTAC' sign_char_fr 'B'],['AC' sign_char_fr]}; %scapula
nb_true_mark = length(true_mark_names);
true_mark_loc = NaN(3,nb_true_mark);
true_mark_coord = NaN(nb_frame,3*nb_true_mark);
R_corr=repmat(eye(4,4),1,1,nb_true_mark);

imark=1;
while imark<=nb_mark || sum(isnan(true_mark_loc(1,:)))~=0, 
for i_true_mark=1:nb_true_mark
    if strcmp(st_model.Model.MarkerSet.objects.Marker(imark).ATTRIBUTE.name,true_mark_names{i_true_mark}), 
        true_mark_seg = st_model.Model.MarkerSet.objects.Marker(imark).body;
        cur_seg =  1; while ~strcmp(st_model.Model.BodySet.objects.Body(cur_seg).ATTRIBUTE.name,true_mark_seg)
                             cur_seg = cur_seg+1; end 
        offset_cm = st_model.Model.BodySet.objects.Body(cur_seg).mass_center'; 
%         % R_corr = [[0 -1 0;1 0 0;0 0 1] offset_cm;0 0 0 1];% hyp: les axes de OS sont tournés de 90° par rapport aux axes ISB
%         R_corr(:,4,i_true_mark) = [0 -1 0 0;1 0 0 0;0 0 1 0;0 0 0 1]* [offset_cm;1];% hyp: les axes de OS sont tournés de 90° par rapport aux axes ISB       
        true_mark_loc(:,i_true_mark) = st_model.Model.MarkerSet.objects.Marker(imark).location;%+offset_cm';
    end
end
imark=imark+1;
end

% Transférer au référentiel global au cours mouvement
for iframe=1%:nb_frame
    for i_true_mark = 1:nb_true_mark;
        if i_true_mark<=4,
            true_mark_coord_temp = TR0_TH(:,:,iframe)* [true_mark_loc(:,i_true_mark);1];
            true_mark_coord(iframe,i_true_mark*3-2:i_true_mark*3)= true_mark_coord_temp(1:3);
        else
            true_mark_coord_temp = TR0_SC(:,:,iframe)*[true_mark_loc(:,i_true_mark);1];
            true_mark_coord(iframe,i_true_mark*3-2:i_true_mark*3)= true_mark_coord_temp(1:3);
        end 
    end
fig=figure(1);plot_mark(true_mark_names,true_mark_coord(1,:),[1 0 1],fig)%magenta
                
%     TR0_TH_verif = mark_2_mat('thorax',true_mark_coord(iframe,1:3),true_mark_coord(iframe,4:6),true_mark_coord(iframe,7:9))
    TR0_SC_verif = mark_2_mat('scapula',true_mark_coord(iframe,end-2:end),true_mark_coord(iframe,10:12),true_mark_coord(iframe,13:15),true_mark_coord(iframe,16:18),1)
    TR0_SC(:,:,1)
end

end

