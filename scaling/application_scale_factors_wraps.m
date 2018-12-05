function tree_out=application_scale_factors_wraps(tree,scaling_factors)

tree_out=tree;
list_bodies=extract_KinChainData_ModelOS(tree);
list_bodies=fieldnames(list_bodies);
nb_bodies=size(list_bodies,1);
Rxyz_body2wrap(4,4)=0;

for i_body=1:nb_bodies
    cur_body=list_bodies{i_body};
    if isfield(tree.Model.BodySet.objects.Body(i_body).WrapObjectSet,'objects')
        if isfield(tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects,'WrapEllipsoid')
            nb_wrap=size(tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid,2);
            for i_wrap=1:nb_wrap
%                 xyz_body_rotation=tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).xyz_body_rotation;
%                 tree_out.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).xyz_body_rotation(1)=...
%                     atan(tan(xyz_body_rotation(1))*scaling_factors.(cur_body)(3)/scaling_factors.(cur_body)(2));
%                 tree_out.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).xyz_body_rotation(2)=...
%                     atan(tan(xyz_body_rotation(2))*scaling_factors.(cur_body)(1)/scaling_factors.(cur_body)(3));
%                 tree_out.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).xyz_body_rotation(3)=...
%                     atan(tan(xyz_body_rotation(3))*scaling_factors.(cur_body)(2)/scaling_factors.(cur_body)(1));
                
                tree_out.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).translation=...
                    tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).translation.*scaling_factors.(cur_body);
                tree_out.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).dimensions=...
                    tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).dimensions.*scaling_factors.(cur_body);
                
%                 Rx_body2wrap=Mrot_rotation_axe_angle([1 0 0],tree_out.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).xyz_body_rotation(1),'radians');
%                 Ry_body2wrap=Mrot_rotation_axe_angle([0 1 0],tree_out.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).xyz_body_rotation(2),'radians');
%                 Rz_body2wrap=Mrot_rotation_axe_angle([0 0 1],tree_out.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).xyz_body_rotation(3),'radians');               
%                 Rxyz_body2wrap(1:3,1:3)=Rx_body2wrap*Ry_body2wrap*Rz_body2wrap;
%                 Rxyz_body2wrap(1:4,4)=[tree_out.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).translation 1]';
%                 dimensions= Rxyz_body2wrap'*[scaling_factors.(cur_body) 0]'.*[tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).dimensions 0]';
%                 tree_out.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects.WrapEllipsoid(i_wrap).dimensions=dimensions(1:3)';
            end
        elseif isfield(tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects,'WrapCylinder')
            
            disp('WrapCylinder non scalé') % A faire si besoin
        elseif isfield(tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects,'WrapCylinderObst')
            disp('WrapCylinderObst non scalé') % A faire si besoin
        elseif isfield(tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects,'WrapDoubleCylinderObst')
            disp('WrapDoubleCylinderObst non scalé') % A faire si besoin
        elseif isfield(tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects,'WrapSphere')
            disp('WrapSphere non scalé') % A faire si besoin
        elseif isfield(tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects,'WrapSpehreObst')
            disp('WrapSpehreObst non scalé') % A faire si besoin
        elseif isfield(tree.Model.BodySet.objects.Body(i_body).WrapObjectSet.objects,'WrapTorus')
            disp('WrapTorus non scalé') % A faire si besoin
        end
    end
end





end