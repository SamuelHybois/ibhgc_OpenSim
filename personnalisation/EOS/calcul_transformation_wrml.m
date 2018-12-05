function [ transformation,MH_R1R2 ] = calcul_transformation_wrml( ch_input_droit, ch_input_tourne,affichage )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

movie_init=lire_fichier_wrml(ch_input_droit);
if affichage==1
affiche_objet_movie(movie_init);
end

movie_tourne=lire_fichier_wrml(ch_input_tourne);
if affichage==1
affiche_objet_movie(movie_tourne);
end

[~,transformation]=Recalage_svd(movie_tourne.Noeuds,movie_init.Noeuds);
MH_R1R2 = [transformation.MR2R1',transformation.translation;0,0,0,1];



end

