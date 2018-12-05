function [res_RMSE,table_RMSE,RMSE_partiel]= OS_CalculMarqueursVirtuelAnalyse...
(rep_global,cur_sujet,cur_activity,cur_acquisition,...
struct_OSIM,st_protocole)
%% Objectif :
% - recalculer la position des marqueurs virtuels du modèle
% issus de la simulation par OpenSim afin d'en déterminer le RMSE.
% - calculer le centre de masse du sujet (via l'analyse)


% Initialisation
mass_center=struct;
angles_bodies=struct;
% geometrypath=fullfile(rep_global,cur_sujet,'modele','Geometry');
Analyzefolder = [cur_acquisition(1:end-4) '_' 'ANALYZE'];
[~,my_pos_global_name] = PathContent_Type(fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder),'pos_global.sto') ;
BK_pos_sto=fullfile(rep_global,cur_sujet,cur_activity,Analyzefolder,my_pos_global_name{1});


donnees_trc=lire_donnees_trc(fullfile(rep_global,cur_sujet,cur_activity,cur_acquisition));
coord_BK=load_sto_file(BK_pos_sto);
list_coord_BK=fieldnames(coord_BK);
nb_coord_BK = size(list_coord_BK,1);
nb_frame_BK = size(coord_BK.(list_coord_BK{1}),1);

%lecture du modèle OSIM
st_model = struct_OSIM;

%lecture des centres de masse et de leur orientation
for i_coord=1:nb_coord_BK
    cur_nom_coord=list_coord_BK{i_coord};
    cur_value_coord=coord_BK.(cur_nom_coord);
    if strcmp(cur_nom_coord,'time')==0 && ~isempty(strfind(cur_nom_coord,'ground'))==0
        if ~isempty(strfind(cur_nom_coord,'_Ox')) || ~isempty(strfind(cur_nom_coord,'_Oy')) || ~isempty(strfind(cur_nom_coord,'_Oz'))
            cur_body=cur_nom_coord(1:end-3);
            if isfield(angles_bodies,cur_body)==0
                angles_bodies.(cur_body)=cur_value_coord;
            else
                angles_bodies.(cur_body)=[angles_bodies.(cur_body) cur_value_coord];
            end
        elseif ~isempty(strfind(cur_nom_coord,'_X')) || ~isempty(strfind(cur_nom_coord,'_Y')) || ~isempty(strfind(cur_nom_coord,'_Z'))
            cur_body=cur_nom_coord(1:end-2);
            if isfield(mass_center,cur_body)==0
                mass_center.(cur_body)=cur_value_coord;
            else
                mass_center.(cur_body)=[mass_center.(cur_body) cur_value_coord];
            end
        end
    end
end

% Calcul des matrices homogènes des segments
Struct_MH=calcul_MH_reconstruction_analyse(st_model,angles_bodies,mass_center);

% Calcul des positions des marqueurs provenant du trc
coord_trc=struct;
for i_marker=1:length(donnees_trc.noms)
    nom_mrk_trc=donnees_trc.noms{i_marker};
    if ~strcmp(nom_mrk_trc(1:end-2),'C_')==1
        coord_trc.(nom_mrk_trc)=donnees_trc.coord(:,i_marker*3-2:i_marker*3); 
    end
end

% Lecture des positions des marqueurs dans le modèle osim (coordonnées
% relatives, dans chaque segment).
coord_R0=struct;
MH_body=zeros(4,4,nb_frame_BK);

for i_frame = 1:nb_frame_BK % On passe les coordonnées des marqueurs des segments vers R0
    for i_marker=1:length(st_model.Model.MarkerSet.objects.Marker)
        Name_Body_for_marker=st_model.Model.MarkerSet.objects.Marker(i_marker).body;
        coord_marker=st_model.Model.MarkerSet.objects.Marker(i_marker).location;
        MH_body(:,:,i_frame)=Struct_MH.(Name_Body_for_marker).MH(:,:,i_frame);
        coord_marker_R0=MH_body(:,:,i_frame)*[coord_marker 1]';
        nom_mrk_R0=st_model.Model.MarkerSet.objects.Marker(i_marker).ATTRIBUTE.name;
        coord_R0.(nom_mrk_R0)(i_frame,:)=coord_marker_R0(1:3)';
    end
end

% [bodies] = extract_KinChainData_ModelOS(st_model);
st_mrk=st_model.Model.MarkerSet.objects.Marker;
for i_mrk=1:size(st_mrk,2)
    cur_body=st_mrk(i_mrk).body;
    cur_location=st_mrk(i_mrk).location;
    cur_mrk=st_mrk(i_mrk).ATTRIBUTE.name;
    st_bodies_mrk.(cur_body).(cur_mrk)=cur_location;
end

% figure
% hold on
% list_mrk_R0=fieldnames(coord_R0);
% for i_mrk=1:size(list_mrk_R0,1)
%     cur_mrk=list_mrk_R0{i_mrk};
%     scatter3(coord_R0.(cur_mrk)(1,1),coord_R0.(cur_mrk)(1,2),coord_R0.(cur_mrk)(1,3),50,'red')
%     scatter3(coord_trc.(cur_mrk)(1,1),coord_trc.(cur_mrk)(1,2),coord_trc.(cur_mrk)(1,3),50,'blue')
% end
[res_RMSE,table_RMSE,RMSE_partiel]=calcul_RMSE_dual_par_body(coord_trc,coord_R0,st_bodies_mrk,st_protocole); % diff: n_lignes x m_colonnes avec n le nombre de frame et m le nombre de marqueurs
save(fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder,'res_RMSE.mat'),'res_RMSE');
% save(fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder,'Struct_MH.mat'),'Struct_MH');

end
