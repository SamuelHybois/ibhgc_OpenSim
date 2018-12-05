function R0_Rseg = segment_matrix_from_mot(st_model,st_mot,segment)

%%% IN PROGRESS %%%%%


%% A UTILISER SI ON N'A SEULEMENT LES COORDONNEES GENERALISEES SANS LES MARQUEURS %%%
%% 1. Reperer le segment dans l'espace du laboratoire
% % Identifier les segments du modele
% st_body = st_model.Model.BodySet.objects.Body; 
% nb_seg = length(st_body);
% list_seg = cell(nb_seg,1);
% for iseg = 1:nb_seg, 
%     list_seg{iseg} = st_body(iseg).ATTRIBUTE.name; 
% end
% 
% % Construire la matrice de passage vers le segment parent jusqu'à la racine
% cur_body = segment;
% while ~strcmp(cur_body,'ground')
%     cur_num = find(strcmp(list_seg,cur_body)); 
%     cur_joint = fieldnames(st_body(cur_num).Joint);
%     st_joint = eval(sprintf('st_body(cur_num).Joint.%s',char(cur_joint)));  
%     
%     
%     % Matrice de passage du segment parent à l'articulation
%     parent_body = st_joint.parent_body;    
%     loc_in_parent = st_joint.location_in_parent;
%     or_in_parent = st_joint.oriention_in_parent;
%     MH_in_parent = ;
%     
%     % Matrice de passage du segment actuel à l'articulation
%     loc_in_cur = st_joint.location;
%     or_in_cur = st_joint.oriention;
%     MH_in_parent = ;    
%     
%     % Matrice de passage de la position anatomique à la position en movement
%     st_coord = st_joint.CoordinateSet.objects.Coordinate;
%     nb_coord = length(st_coord);
%     for icoord = 1:nb_coord
%        motion_type = st_coord(icoord).motion_type;
%        motion_name = st_coord(icoord).ATTRIBUTE.name;
%        motion_num = find(strcmp(motion_name,fieldnames(st_mot)));
%        motion_value = st_mot(motion_num);
%         
%     end
%     
%     cur_body = parent_body;
% end

%% 2. Extraire la structure des coordonnees de marqueurs
st_mark = st_model.Model.MarkerSet.objects.Marker;
nb_mark = length(st_mark);
nb_frame = eval(sprintf('length(st_mot.%s_tx)',st_mark(1).ATTRIBUTE.name));

list_mark = cell(nb_mark,1);
coord_model = NaN(1,nb_mark*3);
coord_mot = NaN(nb_frame,nb_mark*3);

for imark = 1:nb_mark
   name_mark = st_mark(imark).ATTRIBUTE.name; 
   list_mark{imark} = [name_mark];   
   coord_model(imark*3-2:imark*3) = st_mark(imark).location;   
   xcoord_mot = eval(sprintf('st_mot.%s_tx',name_mark));
   ycoord_mot = eval(sprintf('st_mot.%s_ty',name_mark));
   zcoord_mot = eval(sprintf('st_mot.%s_tz',name_mark));
   coord_mot(:,imark*3-2:imark*3) = [xcoord_mot' ycoord_mot' zcoord_mot'];
end

st_mark_model = struct('noms',{[list_mark]},'coord',coord_model);
st_mark_mot = struct('noms',{[list_mark]},'coord',coord_mot);

%% 3. Calculer le repère de passage du segment au global
% % Matrice de passage du segment aux marqueurs du modele (<modele)
Rseg_Rmark = segment_matrix_from_trc(st_mark_model,segment);

% Matrice de passe du global aux marqueurs du modele (<.mot)
R0_Rmark = segment_matrix_from_trc(st_mark_mot,segment);

%Matrice de passage du global au segment opensim
R0_Rseg = repmat(eye(4,4),1,1,nb_frame);
for iframe = 1:nb_frame
    R0_Rseg(:,:,iframe) = R0_Rmark*inv(Rseg_Rmark);
end

end