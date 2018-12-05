function M_pass=passage_Euler_R0(St_Segment,Angles_seg)
TypeJoint=fieldnames(St_Segment.Joint);
nb_frame=size(Angles_seg,1);
if ~isempty(TypeJoint)
    if ~isempty(find(strcmp(fieldnames(St_Segment.Joint.(TypeJoint{1})),'SpatialTransform'), 1)) % On enlève les segments qui n'ont pas de spatial transform à savoir le weld joint et on enlève aussi le ground
        sequence=[St_Segment.Joint.(TypeJoint{1}).SpatialTransform.TransformAxis(1).axis',... % Penser à s'occuper de la scapula
            St_Segment.Joint.(TypeJoint{1}).SpatialTransform.TransformAxis(2).axis',...
            St_Segment.Joint.(TypeJoint{1}).SpatialTransform.TransformAxis(3).axis'];
        num_angle(1)=find(sequence(:,1),1);
        num_angle(2)=find(sequence(:,2),1);
        for i_frame=1:nb_frame
            Rot1=Mrot_rotation_axe_angle(sequence(:,1),Angles_seg(i_frame,num_angle(1)));
            Rot2=Mrot_rotation_axe_angle(sequence(:,2),Angles_seg(i_frame,num_angle(2)));
            M_pass(1,:,i_frame)=sequence(:,1);
            M_pass(2,:,i_frame)=Rot1*sequence(:,2);
            M_pass(3,:,i_frame)=Rot1*Rot2*sequence(:,3);
            M_pass(:,:,i_frame)=M_pass(:,:,i_frame)*sequence;
        end
    else
        for i_frame=1:nb_frame
            M_pass(:,:,i_frame)=eye(3,3);
        end
    end
end
end