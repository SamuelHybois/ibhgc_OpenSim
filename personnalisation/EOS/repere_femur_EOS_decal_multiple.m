function femur=repere_femur_EOS_decal_multiple(file_wrl_femur,file_ddr_femur,decal_TF, decal_cond_int, decal_cond_ext)

% Femoral anatomical frame from a movie femur
obj_wrl_femur=lire_fichier_vrml(file_wrl_femur);
obj_ddr_femur= lire_fichier_ddr(file_ddr_femur);

struct_ddr=RegtyI2tyII(obj_ddr_femur,'Polygones');


[CondyleExt] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.CondyleExt.Polygones,obj_wrl_femur);
[CondyleInt] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.CondyleInt.Polygones,obj_wrl_femur);
[Tetefemorale] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.TeteFemorale.Polygones,obj_wrl_femur);

ctf = sphere_moindres_carres(Tetefemorale.Noeuds);
cond_ext = sphere_moindres_carres(CondyleExt.Noeuds);
cond_ext =cond_ext.Centre + decal_cond_ext';
cond_int = sphere_moindres_carres(CondyleInt.Noeuds);
cond_int=cond_int.Centre+decal_cond_int';
if norm(decal_TF)~=0
    ctf=ctf.Centre+decal_TF';
else
    ctf=ctf.Centre;
end
pint=(cond_ext+cond_int)/2;
vect1=(ctf-pint)/norm(ctf-pint);
vectint=(cond_ext-cond_int)/norm(cond_ext-cond_int);
vect2=cross(vect1,vectint);
vect3=cross(vect2,vect1);


vectcentre=ctf;
vectX=vect2;
vectY=vect1;
vectZ=vect3;

femur = [vectX;vectY;vectZ;vectcentre]';
femur = [femur;0,0,0,1];



