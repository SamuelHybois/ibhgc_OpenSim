function objet_stl_tot=creation_objet_stl_tot(st_model,ind_seg,rep_geometry,nom_segment,bodies_name)
% Fonction pour concaténer les stl d'un même body sous une même structure
% appelée objet_stl_tot
objet_stl=struct;
nb_geometry=size(st_model.Model.BodySet.objects.Body(ind_seg).VisibleObject.GeometrySet.objects.DisplayGeometry,2); % Nombre d'objets géométrie dans le body
nom_objet=cell(nb_geometry);
for i_geometry=1:nb_geometry
    nom_objet{i_geometry}=st_model.Model.BodySet.objects.Body(ind_seg).VisibleObject.GeometrySet.objects.DisplayGeometry(i_geometry).geometry_file;
    cur_vtp=lire_fichier_vtp(fullfile(rep_geometry,nom_objet{i_geometry}));
    objet_stl.objets(i_geometry)=cur_vtp;
end
if strcmp(nom_segment,'pelvis')
    nb_geometry=nb_geometry+1;
    nom_objet{3}='sacrum.vtp';
    cur_vtp=lire_fichier_vtp(fullfile(rep_geometry,nom_objet{3}));
    objet_stl.objets(3)=cur_vtp;
    ind_sacrum=strcmp(bodies_name,'sacrum');
end
flag_dim_polygone=0;
if nb_geometry==1
    objet_stl_tot=objet_stl.objets;
else
    objet_stl_tot.N_obj=1;
    for i_geo=1:nb_geometry
        if strcmp(nom_segment,'pelvis') && i_geo==3
            % Pour le sacrum
            scale_factor_cur_geo=st_model.Model.BodySet.objects.Body(ind_sacrum).VisibleObject.GeometrySet.objects.DisplayGeometry(1).scale_factors;
        else
            scale_factor_cur_geo=st_model.Model.BodySet.objects.Body(ind_seg).VisibleObject.GeometrySet.objects.DisplayGeometry(i_geo).scale_factors;
        end
        if i_geo==1
            objet_stl_tot.Normales=objet_stl.objets(i_geo).Normales;
            objet_stl_tot.Noeuds=objet_stl.objets(i_geo).Noeuds.*repmat(scale_factor_cur_geo,[size(objet_stl_tot.Normales,1),1]);
            objet_stl_tot.Polygones=objet_stl.objets(i_geo).Polygones;
        else
            nb_noeud_prec=size(objet_stl_tot.Noeuds,1);
            objet_stl_tot.Normales=[objet_stl_tot.Normales;objet_stl.objets(i_geo).Normales];
            objet_stl_tot.Noeuds=[objet_stl_tot.Noeuds;objet_stl.objets(i_geo).Noeuds.*repmat(scale_factor_cur_geo,[size(objet_stl.objets(i_geo).Noeuds,1),1])];
            if flag_dim_polygone==0 && size(objet_stl.objets(i_geo).Polygones,2)~=3 % Si on a un objet qui a des polygones définis avec 4 noeuds, on
                objet_stl_tot.Polygones(:,4)=NaN;
                flag_dim_polygone=1;
            end
            objet_stl_tot.Polygones=[objet_stl_tot.Polygones;objet_stl.objets(i_geo).Polygones+nb_noeud_prec];
            % il faut ajouter le nombre de noeuds de l'objet précédent
            % aux polygones pour qu'ils correspondent au stl total
        end
    end
end
%Application du scaling sur l'objet total
objet_stl_tot.Noeuds=objet_stl_tot.Noeuds.*repmat(st_model.Model.BodySet.objects.Body(ind_seg).VisibleObject.scale_factors,[size(objet_stl_tot.Noeuds,1),1]);
end