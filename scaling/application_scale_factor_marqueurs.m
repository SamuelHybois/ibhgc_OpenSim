function tree_out=application_scale_factor_marqueurs(tree,scaling_factors)
tree_out=tree;
st_mrk_model=extract_st_mrk_from_model(tree);
list_mrk=fieldnames(st_mrk_model);
nb_mrk=size(list_mrk,1);
for i_mrk=1:nb_mrk
    cur_body=st_mrk_model.(list_mrk{i_mrk}).body;
    if isfield(scaling_factors,cur_body)
        cur_location=st_mrk_model.(list_mrk{i_mrk}).location.*scaling_factors.(cur_body);
        tree_out.Model.MarkerSet.objects.Marker(i_mrk).location=cur_location;
    end
end
end