function angles_derives=calcul_vit_ang_brut(angles,freq)

list_angles=fieldnames(angles);
nb_angles=size(list_angles,1);
angles_derives=struct;

for i_angle=1:nb_angles
    cur_angle=list_angles{i_angle};
    if ~isempty(strcmp(cur_angle,'time'))
        nb_pts=size(angles.(cur_angle),1);
        for i = 1:nb_pts-1
            for i_coord=1:3
%                 angles_derives.(cur_angle)(i,i_coord)         =   (-angles.(cur_angle)(i+2,i_coord)+8*angles.(cur_angle)(i+1,i_coord)-8*angles.(cur_angle)(i-1,i_coord)+angles.(cur_angle)(i-2,i_coord))/(12*(1/freq));
                angles_derives.(cur_angle)(i,i_coord)         =   (angles.(cur_angle)(i+1,i_coord)-angles.(cur_angle)(i,i_coord))/(1/freq);
%                 angles_derives.(cur_angle)(1,i_coord)         =   (angles.(cur_angle)(2,i_coord)-angles.(cur_angle)(1,i_coord))/(1/freq);
%                 angles_derives.(cur_angle)(2,i_coord)         =   (angles.(cur_angle)(3,i_coord)-angles.(cur_angle)(1,i_coord))/(2*(1/freq));
%                 angles_derives.(cur_angle)(nb_pts-1,i_coord)  =   (angles.(cur_angle)(end,i_coord)-angles.(cur_angle)(end-2,i_coord))/(2*(1/freq));
                angles_derives.(cur_angle)(nb_pts,i_coord)    =   (angles.(cur_angle)(end,i_coord)-angles.(cur_angle)(end-1,i_coord))/((1/freq));
            end
        end
        
    end
end