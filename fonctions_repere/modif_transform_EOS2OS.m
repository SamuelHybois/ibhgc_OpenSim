function cur_st_model=modif_transform_EOS2OS(cur_st_model,repere,ind_os,num_geo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fonction pour remplacer le transform des géométries du modèle OpenSim
% En entrée : cur_st_model est la structure du modèle OpenSim, repere est le repere de
% l'os que l'on veut changer, ind_os est l'indice de l'os que l'on veut
% changer dans la structure cur_st_model, num_geo est le numéro associé au
% geomtryset dans le cas du tibia et de la fibula par exemple, num_geo=1
% pour le tibia et num_geo=2 pour la fibula
%
% En sortie : cur_st_model avec le transform modifié
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[angles]=axemobile_xyz(repere(1:3,1:3)'); % on récupère les angles 
angles=2*pi/360*angles; % Conversion en radians
vect=-repere(1:3,1:3)'*repere(1:3,4); % On tourne le vecteur position
vect=vect/1000; % Conversion en m

cur_st_model.Model.BodySet.objects.Body(ind_os).VisibleObject.GeometrySet.objects.DisplayGeometry(num_geo).transform=[angles vect'];

end