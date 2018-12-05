function [ MH_tib, pt_malleole ] = calcul_repere_tibia_mod_avec_malleoles( file_wrl_tibia , region_tibia )
% fonction de calcul du repère tibia
% Modification Maxime Bourgain février 2016

% Cette fonction permet de calculer la matrice homogène du repères tibia à
% partir des fichiers ddr et wrl. 
% Elle permet aussi de sortir les coordonnées du centre (ou du barycentre)
% des malléoles. Attention la malléole n'est pas exprimée dans le repère
% tibia, mais dans le repère initial des datas.


% lire le fichier DDr
Reg=lire_fichier_ddr(region_tibia);
reg_tib=RegtyI2tyII(Reg,'Polygones');

% lire le fichier wrl
Objet_tibia=lire_fichier_vrml(file_wrl_tibia);

[Pilon] = ISOLE_SURF_MAILLAGE('Polygones',reg_tib.TibiaDist.Polygones,Objet_tibia);
[PlateauExt] = ISOLE_SURF_MAILLAGE('Polygones',reg_tib.PlatExt.Polygones,Objet_tibia);
[PlateauInt] = ISOLE_SURF_MAILLAGE('Polygones',reg_tib.PlatInt.Polygones,Objet_tibia);
[malleoles]=ISOLE_SURF_MAILLAGE('Polygones',reg_tib.Malleoles.Polygones,Objet_tibia);
pt_malleole=barycentre(malleoles.Noeuds);

%% seconde définition pour l'obtention du centre des maléolles
% [malleole_int] = ISOLE_SURF_MAILLAGE('Polygones',reg_tib.Malleole_Int.Polygones,Objet_tibia);
% [malleole_ext] = ISOLE_SURF_MAILLAGE('Polygones',reg_tib.Malleole_Ext.Polygones,Objet_tibia);
% pt_malleole_int=sphere_moindres_carres(malleole_int.Noeuds);
% pt_malleole_int=pt_malleole_int.Centre;
% pt_malleole_ext=sphere_moindres_carres(malleole_ext.Noeuds);
% pt_malleole_ext=pt_malleole_ext.Centre;
% pt_malleole=0.5*(pt_malleole_ext+pt_malleole_int);

pt_tib.lat = barycentre(PlateauExt.Noeuds);
pt_tib.med = barycentre(PlateauInt.Noeuds);
pt_tib.pilon = barycentre(Pilon.Noeuds);

centre=(pt_tib.lat+pt_tib.med)/2;

j = (centre-pt_tib.pilon)/norm(centre-pt_tib.pilon);


i= cross((pt_tib.med - centre),j)...
    /norm(cross((pt_tib.med - centre),j),2);

k = cross(i,j);

MH_tib=[ i' j' k' centre'; 0 0 0 1];


% repere_tib.Matriceh = [ repere_tib.i' , repere_tib.j' ,repere_tib.k'];
% repere_tib.Matriceh(:,4) = repere_tib.centre;
% repere_tib.Matriceh(4,:) = [0,0,0,1];
end

