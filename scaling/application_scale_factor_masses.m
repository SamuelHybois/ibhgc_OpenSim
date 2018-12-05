function tree_out=application_scale_factor_masses(tree,scaling_factors)

tree_out=tree;
list_bodies=extract_KinChainData_ModelOS(tree);
list_bodies=fieldnames(list_bodies);
nb_bodies=size(list_bodies,1);
for i_body=1:nb_bodies
    cur_body=list_bodies{i_body};
    if ~strcmp(cur_body,'ground') && isfield(scaling_factors,cur_body)
        tree_out.Model.BodySet.objects.Body(i_body).mass_center=tree.Model.BodySet.objects.Body(i_body).mass_center.*scaling_factors.(cur_body);
    end
end

end