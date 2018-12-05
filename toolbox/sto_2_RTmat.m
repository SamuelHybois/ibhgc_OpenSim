function RT = sto_2_RTmat(segment,dof_data,dof_names,st_model)
% Cette fonction permet de reconstruire les matrice 4x4 des segments dans
% le référentiel global, à partir des coordonnées données par OS dans le 
% fichier .sto (ces coordonnées sont la position du centre de masse
% segmentatire et l'orientation du repère segment -def ISB- suivant une
% sequence d'Euler XYZ)
%                                                               Diane H
%                                                               05/04/18

% Identification du segment
cur_seg =  1;
while ~strcmp(st_model.Model.BodySet.objects.Body(cur_seg).ATTRIBUTE.name,segment)
    cur_seg = cur_seg+1;
end

% Homogeneous matrix in global
nb_frame = size(dof_data,1);
RT = repmat(eye(4,4),[1,1,nb_frame]);
     
% Offsets center of mass segment and joint pour correspondre aux
% recomandations de l'ISB
offset_cm = st_model.Model.BodySet.objects.Body(cur_seg).mass_center';
if strcmp(segment,'scapula_r')||strcmp(segment,'scapula_l'),
    joint_or = st_model.Model.BodySet.objects.Body(cur_seg).Joint.ScapulothoracicJoint.orientation_in_parent*pi/180;
    [or_x,or_y,or_z] = Rotations2Matrix_xyz(joint_or(1),joint_or(2),joint_or(3));
    joint_or_matrix = eye(4,4);
    joint_or_matrix(1:3,1:3) = or_x*or_y*or_z;
    joint_loc = st_model.Model.BodySet.objects.Body(cur_seg).Joint.ScapulothoracicJoint.location_in_parent';    
else
    joint_or_matrix = eye(4,4);
    joint_loc = [0,0,0];
end

% Degrees of freedom segment
num_seg_x = find(strcmp([segment '_X'],dof_names));
num_seg_y = find(strcmp([segment '_Y'],dof_names));
num_seg_z = find(strcmp([segment '_Z'],dof_names));
num_seg_Ox = find(strcmp([segment '_Ox'],dof_names));
num_seg_Oy = find(strcmp([segment '_Oy'],dof_names));
num_seg_Oz = find(strcmp([segment '_Oz'],dof_names));

% Generalized segment kinematics
x = (dof_data(:,num_seg_x)-(offset_cm(1)+joint_loc(1)));%
y = (dof_data(:,num_seg_y)-(offset_cm(2)+joint_loc(2)));%
z = (dof_data(:,num_seg_z)-(offset_cm(3)+joint_loc(3)));%
Ox = dof_data(:,num_seg_Ox)*pi/180; % les angles du fichier .sto sont 
Oy = dof_data(:,num_seg_Oy)*pi/180; % en degrés
Oz = dof_data(:,num_seg_Oz)*pi/180;

for iframe=1:nb_frame
    [R1,R2,R3] = Rotations2Matrix_xyz(Ox(iframe),Oy(iframe),Oz(iframe)); % sequence x,y,z
    Orientation = R1*R2*R3; % sequence x,y,z 
    Translation = [x(iframe); y(iframe); z(iframe)];
    RT(:,:,iframe) = [Orientation, Translation; 0,0,0,1]*joint_or_matrix;  
end %iframe 

end %function