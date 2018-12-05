function list_mrk=extract_mrkName_modelOS(st_model)
nb_mrk=size(st_model.Model.MarkerSet.objects.Marker,2);
list_mrk={};
for i_mrk=1:nb_mrk;
    list_mrk{end+1}=st_model.Model.MarkerSet.objects.Marker(i_mrk).ATTRIBUTE.name;
end
end