function [ repere_tib ] = calcul_repere_tibia_v2( tibia , region ,cote)
if cote=='G'
sens='Gauche';
else
    sens='Droit';
end;
Reg = lire_fichier_ddr( region );
regions_tib=regtyi2tyii(Reg,'element');
regions_tib.TibiaDist=regions_tib.TibiaDistal;
[Repere, Parametre]= Construit_Repere_Tibia_Generique_Scanner(tibia, regions_tib,sens);
repere_tib=Repere;