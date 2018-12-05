function femur=repere_femur_EOS_mod(mod,ddr)

% Femoral anatomical frame from a movie femur

struct_ddr=RegtyI2tyII(ddr,'Polygones');


[Epicondyle_Ext] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr. EpicondExt.Polygones,mod);
[Epicondyle_Med] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.EpicondInt.Polygones,mod);
[Tetefemorale] = ISOLE_SURF_MAILLAGE('Polygones',struct_ddr.TeteFemorale.Polygones,mod);

ctf = sphere_moindres_carres(Tetefemorale.Noeuds);
cond_ext = sphere_moindres_carres(Epicondyle_Ext.Noeuds);
cond_int = sphere_moindres_carres(Epicondyle_Med.Noeuds);


pint=(cond_ext.Centre+cond_int.Centre)/2;
vect1=(ctf.Centre-pint)/norm(ctf.Centre-pint);
vectint=(cond_ext.Centre-cond_int.Centre)/norm(cond_ext.Centre-cond_int.Centre);
A=dot(vectint,[0,1,0]);
if A>0
    vectint=-vectint;
end
    
vect2=cross(vect1,vectint);
vect3=cross(vect2,vect1);


vectcentre=ctf.Centre;
vectX=vect2;
vectY=vect1;
vectZ=vect3;

femur = [vectX;vectY;vectZ;vectcentre]';
femur = [femur;0,0,0,1];



