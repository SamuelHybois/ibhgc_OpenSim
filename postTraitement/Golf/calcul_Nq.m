function Nq=calcul_Nq(St_Segment,Angles_seg)
TypeJoint=fieldnames(St_Segment.Joint);
nb_frame=size(Angles_seg,1);
if ~isempty(TypeJoint)
    if ~isempty(find(strcmp(fieldnames(St_Segment.Joint.(TypeJoint{1})),'SpatialTransform'), 1)) % On enlève les segments qui n'ont pas de spatial transform à savoir le weld joint et on enlève aussi le ground
        sequence=[St_Segment.Joint.(TypeJoint{1}).SpatialTransform.TransformAxis(1).axis',... % Penser à s'occuper de la scapula
            St_Segment.Joint.(TypeJoint{1}).SpatialTransform.TransformAxis(2).axis',...
            St_Segment.Joint.(TypeJoint{1}).SpatialTransform.TransformAxis(3).axis'];
        %% Base proximale :
        p1=sequence(:,1);
        
        num_angle(1)=find(sequence(:,1),1);
        num_angle(2)=find(sequence(:,2),1);
        num_angle(3)=find(sequence(:,3),1);
        
        for i_frame=1:nb_frame
            %% Base distale :
            dist_basis=[sequence(:,1),sequence(:,2),sequence(:,3)];
            Rot1=Mrot_rotation_axe_angle(dist_basis(:,1),Angles_seg(i_frame,num_angle(1)));
            Rot2=Mrot_rotation_axe_angle(dist_basis(:,2),Angles_seg(i_frame,num_angle(2)));
            Rot3=Mrot_rotation_axe_angle(dist_basis(:,3),Angles_seg(i_frame,num_angle(3)));
            MH_dist(1:3,1:3)=Rot1*Rot2*Rot3;
            d3=MH_dist(1:3,2);
            
            %% Base d'Euler :
            g_1=p1;
            g_3=d3;
            g_2=cross(d3,p1)/norm(cross(d3,p1));
            %             Rot1=Mrot_rotation_axe_angle(sequence(:,1),Angles_seg(i_frame,num_angle(1)));
            %             Rot2=Mrot_rotation_axe_angle(sequence(:,2),Angles_seg(i_frame,num_angle(2)));
            %% Base duale d'Euler :
            g=cross(g_1,g_2)'*g_3;
            g1=1/g*cross(g_2,g_3);
            g2=g_2;
            g3=1/g*cross(g_1,g_2);
            
            Nq(1:3,1:3,i_frame)=[g1,g2,g3];
            
        end
    else
        for i_frame=1:nb_frame
            Nq(:,:,i_frame)=eye(3,3);
        end
    end
end







end
