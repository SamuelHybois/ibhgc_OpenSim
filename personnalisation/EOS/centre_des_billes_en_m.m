function [marqueurs]=centre_des_billes_en_m(repgen)

% repgen='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstruction_6\bille_mod';
% Relabel_bille_EOS

[rep, files]=PathContent(repgen);
filelist=select_files_extension(files, '.wrl');

marqueurs=[];
coordo=[];
for i=1:length(filelist)
    Sphere_wrl=lire_fichier_vrml(fullfile(repgen,filelist{i}));
    [~, cur_nom, ~]=fileparts(fullfile(repgen,filelist{i}));
    Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
    centre= Sphere.Centre;
    coordo=[coordo; centre];
    h=['marqueurs.noms.' cur_nom '=[];'];
    eval(h);
end

marqueurs.coord=coordo*10^(-3);
end
