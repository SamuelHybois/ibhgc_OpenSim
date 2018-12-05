function ecrit_fichier_stl(fichier,movie,nom)

fid=fopen(fichier,'w');
fprintf(fid,'solid %s\n',nom);

A=movie.Noeuds(movie.Polygones(:,1),:);
B=movie.Noeuds(movie.Polygones(:,2),:);
C=movie.Noeuds(movie.Polygones(:,3),:);

N=norme_vecteur(cross(B-A,C-A,2));

fprintf(fid,['facet normal %.13f %.13f %.13f\n' ...
             'outer loop\n' ...
             'vertex %.13f %.13f %.13f\n' ...
             'vertex %.13f %.13f %.13f\n' ...
             'vertex %.13f %.13f %.13f\n' ...
             'endloop\n' ...
             'endfacet\n'],[N A B C]');

fprintf(fid,'endsolid %s\n',nom);
fclose(fid);