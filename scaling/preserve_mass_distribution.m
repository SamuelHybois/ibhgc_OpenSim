function [tree_out,mass_scaling_factor]=preserve_mass_distribution(tree,subject_mass)

tree_out=tree;
list_bodies=extract_KinChainData_ModelOS(tree);
list_bodies=fieldnames(list_bodies);
nb_bodies=size(list_bodies,1);
os_mass_bodies(nb_bodies)=0;
for ibody = 1:nb_bodies
    os_mass_bodies(ibody)=tree.Model.BodySet.objects.Body(ibody).mass;
end    
os_mass = sum(os_mass_bodies);

% for icol=1:size(xls_raw,2)
%     if strcmp(xls_raw{1,icol},'Mass')
%         col_mass=icol;
%     end
% end
% for iline=1:size(xls_raw,1)
%     if strcmp(xls_raw{iline,1},subject_name)
%         line_subject=iline;
%     end
% end
% subject_mass = xls_raw{line_subject,col_mass};

mass_scaling_factor=subject_mass/os_mass;

for i_body=1:nb_bodies
    cur_body=list_bodies{i_body};
    tree_out.Model.BodySet.objects.Body(i_body).mass=tree.Model.BodySet.objects.Body(i_body).mass*mass_scaling_factor;
end

end
