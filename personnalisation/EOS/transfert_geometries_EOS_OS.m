chemin_EOS='E:\etude_modele_rep_EOS\reconstruction_EOS';
chemin_geo_OS='E:\etude_modele_rep_EOS\Geometry';

% % % % list_nom_EOS={'bassin.wrl'; 'FemurG.wrl'; 'FemurD.wrl'; 'TibiaD.wrl'; 'TibiaG.wrl'; 'PeroneD.wrl'; 'PeroneG.wrl'};
% % % % % les noms de fichiers seront les suivants avec .stl en plus.
% % % % list_nom_OS_2={'pelvis'; 'l_femur'; 'femur_r'; 'tibia'; 'l_tibia'; 'fibula'; 'l_fibula'};

list_nom_EOS={'FemurG.wrl'; 'FemurD.wrl'; 'TibiaD.wrl'; 'TibiaG.wrl'; 'PeroneD.wrl'; 'PeroneG.wrl'};
% les noms de fichiers seront les suivants avec .stl en plus.
list_nom_OS_2={'l_femur'; 'femur_r'; 'tibia'; 'l_tibia'; 'fibula'; 'l_fibula'};
if (length(list_nom_EOS)-length(list_nom_OS_2))~=0
    disp('erreur de déclaration des listes de correspondance EOS-OS')
end
format='.stl';
% for i=1:length(list_nom_EOS)
%     list_nom_OS{i}=strcat(list_nom_OS_2{i},'.stl');
%     nom_EOS=list_nom_EOS{i};
%     nom_OS=list_nom_OS{i};
%     vrml2stl(nom_EOS,nom_OS,chemin_EOS,chemin_geo_OS)
%     f=[chemin_EOS '\' nom_EOS];
%     movie=lire_fichier_wrml(f);
%     ecrit_fichier_stl_MB([chemin_geo_OS '\' nom_OS],movie,nom_OS,10^(-3))
% end

% bodies=[];
% nb_bodies_total=13;
% for i=1:nb_bodies_total
%     bodies=[bodies; {modele_gen_data.Model.BodySet.objects.Body(i).ATTRIBUTE.name}];
% end
% 
% Bodies_2.ground.visualisation=[];
% Bodies_2.pelvis.visualisation='pelvis.stl';
% Bodies_2.femur_r.visualisation='femur_r.stl';
% Bodies_2.tibia_r.visualisation={'fibula.stl'; 'tibia.stl'};
% Bodies_2.talus_r.visualisation=[];
% Bodies_2.calcn_r.visualisation=[];
% Bodies_2.toes_r.visualisation=[];
% Bodies_2.femur_l.visualisation='l_femur.stl';
% Bodies_2.tibia_l.visualisation={'l_fibula.stl';'l_tibia.stl';};
% Bodies_2.talus_l.visualisation=[];
% Bodies_2.calcn_l.visualisation=[];
% Bodies_2.toes_l.visualisation=[];
% Bodies_2.torso.visualisation=[];

model_new=[];
nb_bodies=length(fieldnames(Bodies_2));
noms_bodies=fieldnames(Bodies_2);
for i=1:nb_bodies
    cur_nom=noms_bodies{i};
    A=['body_visu=Bodies_2.' cur_nom '.visualisation'];
    eval(A);
    if isempty(body_visu)~=1
    [model_new]=change_scale_geo_model_OS(model_old, i, body_visu);
    end
end
       
 




