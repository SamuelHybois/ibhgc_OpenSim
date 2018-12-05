function MH=calcul_MH_joint(tree,i_body,nb_frame)

%% On va chercher les valeurs par défaut des ddl
TypeJoint=fieldnames(tree.Model.BodySet.objects.Body(i_body).Joint);
TypeJoint=TypeJoint{1};
if strcmpi(TypeJoint,'CustomJoint')
    nb_ddl=size(tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).CoordinateSet.objects.Coordinate,2);
    for i_ddl=1:nb_ddl
        cur_ddl=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).CoordinateSet.objects.Coordinate(i_ddl).ATTRIBUTE.name;
        default_values.(cur_ddl)=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).CoordinateSet.objects.Coordinate(i_ddl).default_value;
    end
    Mrot(4,4,3)=0;
    for i_rotation=1:3
        coordinate=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_rotation).coordinates;
        if isempty(coordinate)
            axe=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_rotation).axis;
            Mrot(1:3,1:3,i_rotation)=Mrot_rotation_axe_angle(axe,0);
        else
            axe=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_rotation).axis;
            Mrot(1:3,1:3,i_rotation)=Mrot_rotation_axe_angle(axe,default_values.(coordinate)*180/pi);
%             if default_values.(coordinate)~=0, 
%                 axe, 
%             end
        end
    end
    MH=Mrot(:,:,1)*Mrot(:,:,2)*Mrot(:,:,3);
    MH(4,4)=1;
    MH=repmat(MH,1,1,nb_frame);
else
    MH=repmat(eye(4,4),1,1,nb_frame);
end