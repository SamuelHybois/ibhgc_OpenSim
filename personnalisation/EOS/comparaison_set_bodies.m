function comparaison_set_bodies( Bodies_1, Bodies_2 )
% verification que tous les éléments de bodies_1 sont dans Bodies_2


noms_bodies_1=fieldnames(Bodies_1);
nb_bodies_1=length(noms_bodies_1);
for i_bodies_1=1:nb_bodies_1
    cur_nom=noms_bodies_1{i_bodies_1};
    if strcmp(cur_nom,'ground')~=1
        verify=isfield(Bodies_2,cur_nom);
        if verify==0
            disp(['probleme de visualisation du Body ' cur_nom])
        end
    end
end




end

