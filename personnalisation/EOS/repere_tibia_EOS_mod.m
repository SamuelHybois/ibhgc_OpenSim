function tibia=repere_tibia_EOS_mod(file_wrl_tibia,file_ddr_tibia)

% Tibial anatomical frame from a movie tibia+perone merged

Objet_tibia=lire_fichier_vrml(file_wrl_tibia);

Reg_tibia= lire_fichier_ddr(file_ddr_tibia);

struct_ddr=RegtyI2tyII(Reg_tibia,'Polygones');


[Malleole_Ext] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.Malleole_Ext.Polygones,Objet_tibia);
[Malleole_Int] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.Malleole_Int.Polygones,Objet_tibia);
[PlateauExt] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.PlateauExt.Polygones,Objet_tibia);
[PlateauInt] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.PlateauInt.Polygones,Objet_tibia);

plateau_lat = barycentre(PlateauExt.Noeuds);
plateau_med = barycentre(PlateauInt.Noeuds);
centre_plateau = (plateau_lat + plateau_med)/2;
malleole_int = barycentre(Malleole_Int.Noeuds);
malleole_ext = barycentre(Malleole_Ext.Noeuds);
centre_malleole = (malleole_int + malleole_ext)/2;

% on forme le plan passant par les 2 plateaux et le centre des malleoles et
% on calcule le vecteur normal a ce plan "median " du tibia
vect_plateau = (plateau_lat-plateau_med)/norm(plateau_lat-plateau_med);
A=dot(vect_plateau,[0,1,0]);
if A>0
    vect_plateau=-vect_plateau;
end
vect_axe_tibia = (centre_plateau-centre_malleole)/norm(centre_plateau-centre_malleole);
vect_normal_plan_median = cross(vect_axe_tibia,vect_plateau);

vectX = vect_normal_plan_median/norm(vect_normal_plan_median);
vectY = vect_axe_tibia;
vectZ = cross(vectX,vectY);
vectcentre = centre_plateau;

tibia = [vectX;vectY;vectZ;vectcentre]';
tibia = [tibia;0,0,0,1];