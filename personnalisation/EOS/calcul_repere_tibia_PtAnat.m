function [ MH_tib,Plat_tib_lat,Plat_tib_med,Pilon_tib] = calcul_repere_tibia_PtAnat( file_wrl_tibia , region_tibia )
% calcule le repère anatomique et sort les positions des points anatomiques
% Modification Maxime Bourgain 27 06 2017
% fonction de calcul du repère tibia
% Modification Maxime Bourgain février 2016

% lire le fichier DDr
Reg=lire_fichier_ddr(region_tibia);
reg_tib=RegtyI2tyII(Reg,'Polygones');

% lire le fichier wrl
Objet_tibia=lire_fichier_vrml(file_wrl_tibia);

[Pilon] = ISOLE_SURF_MAILLAGE('Polygones',reg_tib.TibiaDist.Polygones,Objet_tibia);
[PlateauExt] = ISOLE_SURF_MAILLAGE('Polygones',reg_tib.PlatExt.Polygones,Objet_tibia);
[PlateauInt] = ISOLE_SURF_MAILLAGE('Polygones',reg_tib.PlatInt.Polygones,Objet_tibia);

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
Plat_tib_lat=pt_tib.lat;
Plat_tib_med=pt_tib.med;
Pilon_tib=pt_tib.pilon;

end

