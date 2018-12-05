function st_model=modif_marqueurs_EOS2OS(st_model,rep_wrl,reperes)
mrk_set=st_model.Model.MarkerSet.objects.Marker;
nb_mrk=size(mrk_set,2);
[~,list_complet]=PathContent_Type(fullfile(rep_wrl,'marqueurs','billes_corps_complet'),'.wrl');
[~,list_MinfD]=PathContent_Type(fullfile(rep_wrl,'marqueurs','billes_corps_MID'),'.wrl');
[~,list_MinfG]=PathContent_Type(fullfile(rep_wrl,'marqueurs','billes_corps_MIG'),'.wrl');
list_suppr={};
for i_mrk=1:nb_mrk
    body_mrk=mrk_set(i_mrk).body;
    cur_mrk=mrk_set(i_mrk).ATTRIBUTE.name;
    if ~isempty(find(strcmp(list_complet,[cur_mrk,'.wrl']),1)) % si le marqueur est dans le dossier des marqueurs du corps complet
        cur_list='billes_corps_complet';
        body_mrk='Bassin'; % Alors il n'y a que le bassin comme body possible
    elseif ~isempty(find(strcmp(list_MinfD,[cur_mrk,'.wrl']),1)) % si le marqueur est dans le dossier des marqueurs du membre inf droit
        cur_list='billes_corps_MID';
        if strcmp(body_mrk,'femur_r') % Alors c'est soit le femur droit
            body_mrk='FemurD';
        elseif strcmp(body_mrk,'tibia_r') % Soit le tibia droit
            body_mrk='TibiaD';
        end
    elseif ~isempty(find(strcmp(list_MinfG,[cur_mrk,'.wrl']),1)) % si le marqueur est dans le dossier des marqueurs du membre inf gauche
        cur_list='billes_corps_MIG';
        if strcmp(body_mrk,'femur_l') % Alors c'est soit le femur gauche
            body_mrk='FemurG';
        elseif strcmp(body_mrk,'tibia_l') % Soit le tibia gauche
            body_mrk='TibiaG';
        end
    else
        clear body_mrk
    end
    if exist('cur_list','var')
        repere_body=reperes.(body_mrk)/1000; % On cherche le repère associé à notre marqueur
        cur_mrk_wrl=lire_fichier_vrml(fullfile(rep_wrl,'marqueurs',cur_list,[cur_mrk,'.wrl'])); % on lit le fichier wrl correspondant à notre marqueur
        centre_mrk_EOS = sphere_moindres_carres(cur_mrk_wrl.Noeuds); % On détermine le centre de notre marqueur
        centre_mrk_EOS=centre_mrk_EOS.Centre/1000; % on passe en m
        centre_mrk_seg=repere_body\[centre_mrk_EOS';1]; % On le passe dans le repère segment
        mrk_set(i_mrk).location=centre_mrk_seg(1:3)'; % On injecte dans la structure
    else
        list_suppr{end+1}=cur_mrk;
    end
    clear cur_list
end
st_model.Model.MarkerSet.objects.Marker=mrk_set;


end