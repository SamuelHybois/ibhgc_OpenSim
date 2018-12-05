function [TF,CondyleExt,CondyleInt,femur]=repere_femur_EOS_PtAnat(file_wrl_femur,file_ddr_femur)
% calcule le repère anatomique et sort les positions des points anatomiques
% Modification Maxime Bourgain 27 06 2017

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

CondyleExt=cond_ext.Centre;
CondyleInt=cond_int.Centre;
TF=ctf.Centre;


vectcentre=ctf.Centre;
vectX=vect2;
vectY=vect1;
vectZ=vect3;

femur = [vectX;vectY;vectZ;vectcentre]';
femur = [femur;0,0,0,1];



