function [ repere_tib ] = calcul_repere_tibiaD( tibia , region )
%CALCUL_REPERE_TIBIA_2 Summary of this function goes here
%   Detailed explanation goes here

Reg=lire_fichier_ddr(region);

reg_tib=RegtyI2tyII(Reg,'Polygones');

[Pilon] = ISOLE_SURF_MAILLAGE('Polygones',reg_tib.TibiaDist.Polygones,tibia);
[PlateauExt] = ISOLE_SURF_MAILLAGE('Polygones',reg_tib.PlatPostExt.Polygones,tibia);
[PlateauInt] = ISOLE_SURF_MAILLAGE('Polygones',reg_tib.PlatPostInt.Polygones,tibia);

pt_tib.lat = barycentre(PlateauExt.Noeuds);
pt_tib.med = barycentre(PlateauInt.Noeuds);
pt_tib.pilon = barycentre(Pilon.Noeuds);

repere_tib.centre=(pt_tib.lat+pt_tib.med)/2;

repere_tib.j = (repere_tib.centre-pt_tib.pilon)/norm(repere_tib.centre-pt_tib.pilon);

repere_tib.i= cross((pt_tib.med - repere_tib.centre),repere_tib.j)...
    /norm(cross((pt_tib.med - repere_tib.centre),repere_tib.j),2);

repere_tib.k = cross(repere_tib.i,repere_tib.j);

repere_tib.Matriceh = [ repere_tib.i' , repere_tib.j' ,repere_tib.k'];
repere_tib.Matriceh(:,4) = repere_tib.centre;
repere_tib.Matriceh(4,:) = [0,0,0,1];
end