function post_traitement(tree,file_sto_pos,file_sto_vit,file_ID,file_xls,file_c3d,arg_plot,dossier_sortie,cur_acquisition,nom_sujet)
%% Initialisation
freq=200;

%% Lecture des fichiers
% STO BODY KINEMATICS ANALYZE
coord=load_sto_file(file_sto_pos);
list_coord=fieldnames(coord);
nb_frame = size(coord.(list_coord{1}),1);

% .sto des vitesses des segments sortant de l'analyse d'OpenSim
vit=load_sto_file(file_sto_vit);
list_vit=fieldnames(vit);

% OSIM
[bodies,~]=extract_KinChainData_ModelOS(tree);
list_bodies=fieldnames(bodies);

% Fichier Excel de labellisation
[~,~,raw_xls]=xlsread(file_xls);

%% Détermination frame impact
for i_col=1:size(raw_xls,2)
    if strcmpi(raw_xls{1,i_col},'impact')
        col_impact=i_col;
        col_debut_downswing=i_col-1;
        col_fin=i_col+1;
        break
    end
end
for i_lin=1:size(raw_xls,1)
    if strfind(cur_acquisition,raw_xls{i_lin,1})
        lin_impact=i_lin;
        break
    end
end
origin_start_frame=coord.time(1)*200;

st_para.frame_debut=1;
st_para.frame_debut_downswing=raw_xls{lin_impact,col_debut_downswing}-origin_start_frame;
st_para.frame_impact=raw_xls{lin_impact,col_impact}-origin_start_frame;
st_para.frame_fin=raw_xls{lin_impact,col_fin}-origin_start_frame;


%% Séparation orientation et position des centres de masse provenant de l'analyse de OS
[mass_center,angles_bodies]=separation_sortie_analyse_OS(list_bodies,coord,list_coord);

%% Séparation vitesse de rotation et vitesse linéaire provenant de l'analyse de OS
[~,vit_bodies]=separation_sortie_analyse_OS(list_bodies,vit,list_vit);

%% Calcul des matrices homogènes des segments
Struct_MH=calcul_MH_reconstruction_analyse(tree,angles_bodies,mass_center);

%% Calcul de la séquence dans le plan de swing
portion=0.7;
noms_mark_plan_swing{1}='Club02';
noms_mark_plan_swing{2}='Club03';
noms_mark_plan_swing{3}='Club04';
acq=btk_loadc3d(file_c3d);
markers=NettoieMarkerLabels2(acq.marker_data.Markers);
% try
    [st_plan_swing,~] = CalculePlanSwing(file_c3d,st_para,markers,noms_mark_plan_swing,portion,arg_plot.plan_swing,dossier_sortie);
    
    list_bodies=fieldnames(vit_bodies);
    vit_bodies_plan_swing=struct;
    for i_body=1:size(list_bodies,1)
        cur_body=list_bodies(i_body);
        for i_frame=1:nb_frame
            vit_bodies_plan_swing.(char(cur_body))(i_frame,:)=vit_bodies.(char(cur_body))(i_frame,:)-(vit_bodies.(char(cur_body))(i_frame,:)*st_plan_swing.normale')*st_plan_swing.normale;
        end
    end
    list_segments={'pelvis','thorax','radius_r','humerus_r','hand_r'};
    [~]=calcul_sequence_cine(vit_bodies_plan_swing,list_segments,st_para.frame_impact,st_para.frame_debut_downswing,arg_plot.sequence,dossier_sortie,[cur_acquisition(1:end-4),'_vit_plan_swing']);
% catch
%     disp('Erreur calcul plan swing')
% end

%% Données du modèle osim
coord_R0=struct;
MH_body=zeros(4,4,nb_frame);
for i_frame = 1:nb_frame % On passe les coordonnées des marqueurs des segments vers R0
    for i_marker=1:length(tree.Model.MarkerSet.objects.Marker)
        Name_Body_for_marker=tree.Model.MarkerSet.objects.Marker(i_marker).body;
        coord_marker=tree.Model.MarkerSet.objects.Marker(i_marker).location;
        MH_body(:,:,i_frame)=Struct_MH.(Name_Body_for_marker).MH(:,:,i_frame);
        coord_marker_R0=MH_body(:,:,i_frame)*[coord_marker 1]';
        nom_mrk_R0=tree.Model.MarkerSet.objects.Marker(i_marker).ATTRIBUTE.name;
        coord_R0.(nom_mrk_R0)(i_frame,:)=coord_marker_R0(1:3)';
    end
end

%% Affichage des courbes des vitesses sortant d'OpenSim
% list_vit_new=fieldnames(vit_bodies);
% for i_vit=1:size(fieldnames(vit_bodies),1)
%     nom_vit=list_vit_new{i_vit};
%     figure('Name',['Vitesse de ',nom_vit,' provenant directement d''OpenSim'],'NumberTitle','off')%,'visible','off')
%     time=0:1/freq:(nb_frame-1)/freq;
%     hold on
%     for i_coord=1:size(vit_bodies.(nom_vit),2)
%         plot(time,vit_bodies.(nom_vit)(:,i_coord))
%     end
%     legend(['Vitesse de ',nom_vit,' autour de X'],['Vitesse de ',nom_vit,' autour de Y'],['Vitesse de ',nom_vit,' autour de Z'],'location','NorthWest')
% end

%% Calcul des vitesses des segments
% vit_ang=calcul_vitesse_angulaire(Struct_MH,freq,arg_plot.vitesses_segments);

%% Passage angles dans le repère R0
list_angles_bodies=fieldnames(angles_bodies);
for i_seg=1:size(list_angles_bodies,1)
    cur_seg=list_angles_bodies{i_seg};
    if ~strcmpi(cur_seg,'ground')
        M_pass_Euler_R0.(cur_seg)=passage_Euler_R0(tree.Model.BodySet.objects.Body(i_seg),angles_bodies.(cur_seg));
        Nq.(cur_seg)=calcul_Nq(tree.Model.BodySet.objects.Body(i_seg),angles_bodies.(cur_seg));
%         for i_frame=1:nb_frame
%             angles_bodies_proj.(cur_seg)(i_frame,:)=M_pass_Euler_R0.(cur_seg)(:,:,i_frame)*angles_bodies.(cur_seg)(i_frame,:)';          
%         end
    end
end

%% Calcul vitesses angulaires à partir des coordonnées directement
% vit_ang_brutes=calcul_vit_ang_brut(angles_bodies_proj,freq); % Dérivée simple

%% Passage vitesses dans le repère d'Euler
% list_vit_ang_brutes=fieldnames(vit_ang_brutes);
%
% for i_seg=1:size(list_vit_ang_brutes,1)
%     cur_seg=list_vit_ang_brutes{i_seg};
%     if ~strcmpi(cur_seg,'ground')
%         for i_frame=1:nb_frame
%             vit_ang_brutes.(cur_seg)(i_frame,:)=M_pass_Euler_R0.(cur_seg)(:,:,i_frame)\vit_ang_brutes.(cur_seg)(i_frame,:)';
%         end
%     end
% end

%% Calcul de la séquence cinématique
list_segments={'pelvis','thorax','radius_r','humerus_r','hand_r'};
try
    [~]=calcul_sequence_cine(vit_bodies,list_segments,st_para.frame_impact,st_para.frame_debut_downswing,arg_plot.sequence,dossier_sortie,cur_acquisition);
catch
    disp('Echec du calcul séquence cinématique dans le plan de swing')
end

%% Calcul du X-factor
[~]=calcul_x_factor(coord_R0,nb_frame,freq,arg_plot.X_factor,st_para.frame_debut_downswing,st_para.frame_impact,dossier_sortie,cur_acquisition);
% OK
%% Calcul du Crunch Factor
[~]=calcul_crunch_factor(coord_R0,vit_bodies,freq,arg_plot.Crunch_factor,st_para.frame_impact,dossier_sortie,cur_acquisition);

%% Calcul des puissances des jambes
calcul_puissances(tree,vit_bodies,file_ID,Nq,dossier_sortie,cur_acquisition,freq,arg_plot.Puissances,st_para.frame_impact,st_para.frame_debut_downswing)

%% Affichage du squelette avec les marqueurs provenant du trc et du modèle osim
% frame=nb_frame
% affichage_squelette_test(tree,frame,geometrypath,Struct_MH)
% affichage_marqueurs(coord_trc,'red',frame)
% affichage_marqueurs(coord_R0,'black',frame)

end
