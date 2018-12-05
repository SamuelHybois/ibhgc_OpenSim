function femur=repere_femur_EOS_decallage(file_wrl_femur,file_ddr_femur, decallage_in_EOS)
% le décallage permet de simuler un mauvais positionnement de la tête
% fémorale. 
% le décallage est exprimé dans le repère EOS.

% Femoral anatomical frame from a movie femur
obj_wrl_femur=lire_fichier_vrml(file_wrl_femur);
obj_ddr_femur= lire_fichier_ddr(file_ddr_femur);

struct_ddr=RegtyI2tyII(obj_ddr_femur,'Polygones');


[CondyleExt] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.CondyleExt.Polygones,obj_wrl_femur);
[CondyleInt] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.CondyleInt.Polygones,obj_wrl_femur);
[Tetefemorale] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.TeteFemorale.Polygones,obj_wrl_femur);

ctf = sphere_moindres_carres(Tetefemorale.Noeuds);
cond_ext = sphere_moindres_carres(CondyleExt.Noeuds);
cond_int = sphere_moindres_carres(CondyleInt.Noeuds);


pint=(cond_ext.Centre+cond_int.Centre)/2;
vect1=(ctf.Centre-pint)/norm(ctf.Centre-pint);
vectint=(cond_ext.Centre-cond_int.Centre)/norm(cond_ext.Centre-cond_int.Centre);
vect2=cross(vect1,vectint);
vect3=cross(vect2,vect1);


vectcentre=ctf.Centre+decallage_in_EOS;
vectX=vect2;
vectY=vect1;
vectZ=vect3;

femur = [vectX;vectY;vectZ;vectcentre]';
femur = [femur;0,0,0,1];



