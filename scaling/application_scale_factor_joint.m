function tree_out=application_scale_factor_joint(tree,scaling_factors)
tree_out=tree;
list_bodies=extract_KinChainData_ModelOS(tree);
list_bodies=fieldnames(list_bodies);
nb_bodies=size(list_bodies,1);
for i_body=1:nb_bodies
    cur_body=list_bodies{i_body};
    if ~strcmp(cur_body,'ground') && isfield(scaling_factors,cur_body)
        TypeJoint=fieldnames(tree.Model.BodySet.objects.Body(i_body).Joint);
        cur_parent=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).parent_body;
        if ~strcmp(cur_parent,'ground') && isfield(scaling_factors,cur_parent)
            tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).location_in_parent=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).location_in_parent.*scaling_factors.(cur_parent);
%             orientation_in_parent=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).orientation_in_parent;            
%             tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).orientation_in_parent(1)=atan(tan(orientation_in_parent(1))*scaling_factors.(cur_parent)(3)/scaling_factors.(cur_parent)(2));
%             tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).orientation_in_parent(2)=atan(tan(orientation_in_parent(2))*scaling_factors.(cur_parent)(1)/scaling_factors.(cur_parent)(3));
%             tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).orientation_in_parent(3)=atan(tan(orientation_in_parent(3))*scaling_factors.(cur_parent)(2)/scaling_factors.(cur_parent)(1));
        end
        tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).location=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).location.*scaling_factors.(cur_body);
%         orientation=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).orientation;            
%         tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).orientation(1)=atan(tan(orientation(1))*scaling_factors.(cur_body)(3)/scaling_factors.(cur_body)(2));
%         tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).orientation(2)=atan(tan(orientation(2))*scaling_factors.(cur_body)(1)/scaling_factors.(cur_body)(3));
%         tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint{1}).orientation(3)=atan(tan(orientation(3))*scaling_factors.(cur_body)(2)/scaling_factors.(cur_body)(1));
    end
end

