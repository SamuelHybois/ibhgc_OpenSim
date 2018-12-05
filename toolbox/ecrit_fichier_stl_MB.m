function ecrit_fichier_stl_MB(fichier,movie,nom,convert)
% convert est le facteur d'échelle à appliquer aux données EOS pour passer
% dans le système voulu. 
% facteur conseillé : 10^(-3) car les points EOS sont en mm


fid=fopen(fichier,'w');
fprintf(fid,'solid %s\n',nom);

A=movie.Noeuds(movie.Polygones(:,1),:);
A=A*convert;
B=movie.Noeuds(movie.Polygones(:,2),:);
B=B*convert;
C=movie.Noeuds(movie.Polygones(:,3),:);
C=C*convert;

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
end