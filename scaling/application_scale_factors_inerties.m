function tree_out=application_scale_factors_inerties(tree,scaling_factors)

tree_out=tree;
list_bodies=extract_KinChainData_ModelOS(tree);
list_bodies=fieldnames(list_bodies);
nb_body=size(list_bodies,1);
for i_body=1:nb_body
    cur_body=list_bodies{i_body};
    if tree_out.Model.BodySet.objects.Body(i_body).mass~=0
        scal_Rx=(scaling_factors.(cur_body)(2)^2+scaling_factors.(cur_body)(3)^2)/2;
        scal_Ry=(scaling_factors.(cur_body)(1)^2+scaling_factors.(cur_body)(3)^2)/2;
        scal_Rz=(scaling_factors.(cur_body)(2)^2+scaling_factors.(cur_body)(1)^2)/2;
        tree_out.Model.BodySet.objects.Body(i_body).inertia_xx=tree_out.Model.BodySet.objects.Body(i_body).inertia_xx*scaling_factors.mass*scal_Rx;
        tree_out.Model.BodySet.objects.Body(i_body).inertia_yy=tree_out.Model.BodySet.objects.Body(i_body).inertia_yy*scaling_factors.mass*scal_Ry;
        tree_out.Model.BodySet.objects.Body(i_body).inertia_zz=tree_out.Model.BodySet.objects.Body(i_body).inertia_zz*scaling_factors.mass*scal_Rz;
        if tree_out.Model.BodySet.objects.Body(i_body).inertia_xy~=0
            tree_out.Model.BodySet.objects.Body(i_body).inertia_xy=tree_out.Model.BodySet.objects.Body(i_body).inertia_xy*scaling_factors.mass*(scal_Rx*scal_Ry)^0.5;
            tree_out.Model.BodySet.objects.Body(i_body).inertia_xz=tree_out.Model.BodySet.objects.Body(i_body).inertia_xz*scaling_factors.mass*(scal_Rx*scal_Rz)^0.5;
            tree_out.Model.BodySet.objects.Body(i_body).inertia_yz=tree_out.Model.BodySet.objects.Body(i_body).inertia_yz*scaling_factors.mass*(scal_Rz*scal_Ry)^0.5;
        end
    end
end
end