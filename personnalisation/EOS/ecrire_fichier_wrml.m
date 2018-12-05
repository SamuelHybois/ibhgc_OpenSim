% ecrire_fichier_wrml(A,nom)
%
% A: structure de type objet movie
% nom : nom du fichier de sortie
%
% Fonction d'écriture de fichier wrml 
% La surface devra etre discréditée en triangle
%
function ecrire_fichier_wrml(A,nom) ;
%
% 1. Ouverture du fichier pour l'écriture :
%
fid = fopen(nom,'w') ;
%
% 2. Ecriture de l'entete :
%
fprintf(fid,'%s\n','#VRML V2.0 utf8') ;
fprintf(fid,'%s\n','Transform {') ;
fprintf(fid,'\t%s\n',' children [') ;
fprintf(fid,'\t\t%s\n',' Shape {') ;
fprintf(fid,'%s\n',...
    'appearance Appearance { material Material { diffuseColor 1.00 0.90 0.90  } }');
fprintf(fid,'%s\n','geometry IndexedFaceSet {') ;
fprintf(fid,'%s\n','coord Coordinate {') ;
fprintf(fid,'%s\n','point [') ;
%
% 3. Ecriture des coordonnées des noeuds
%
fprintf(fid,'%.4f  %.4f  %.4f,\n',A.Noeuds') ;
fprintf(fid,'%s\n','] }') ;
fprintf(fid,'%s\n','coordIndex [') ;
%
% 4. Ecriture de la définition des polygones
%
fprintf(fid,'%g,  %g,  %g,  -1,\n',A.Polygones' -1) ;
fprintf(fid,'%s\n','] creaseAngle 3.14 } } ] }') ;
%
% 5. fermeture du fichier texte
%
fclose(fid) ;
%
% Fin de la fonction