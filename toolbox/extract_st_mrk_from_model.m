function [st_mrk,cell_mrk]=extract_st_mrk_from_model(st_model)

marker_set=st_model.Model.MarkerSet.objects.Marker;
nb_mrk=size(marker_set,2);

for i_mrk=1:nb_mrk
    nom_mrk=marker_set(i_mrk).ATTRIBUTE.name;
    mrk_location=marker_set(i_mrk).location;
    mrk_body=marker_set(i_mrk).body;
    
    st_mrk.(nom_mrk).location=mrk_location;
    st_mrk.(nom_mrk).body=mrk_body;
    
    cell_mrk{i_mrk,1}=mrk_body;
    cell_mrk{i_mrk,2}=nom_mrk;
    cell_mrk{i_mrk,3}=mrk_location;
end

end