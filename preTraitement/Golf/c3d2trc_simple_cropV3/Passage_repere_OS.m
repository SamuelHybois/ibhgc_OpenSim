function st_marqueurs_cine=Passage_repere_OS(st_marqueurs_cine,M_pass_OS_Vicon)

list_mrk=fieldnames(st_marqueurs_cine);
nb_mrk=size(list_mrk,1);
for i_mrk=1:nb_mrk
    cur_mrk=list_mrk{i_mrk};
    st_marqueurs_cine.(cur_mrk)=st_marqueurs_cine.(cur_mrk)*M_pass_OS_Vicon;
end
