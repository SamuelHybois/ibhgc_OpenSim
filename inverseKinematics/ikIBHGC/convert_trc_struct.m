function coord_trc = convert_trc_struct(fichierTRC,options)

% Pas d'options : sort une structure dont les fieldnames sont les marqueurs
% Avec option 'matrix' : structure optimisée (noms des marqueurs + matrice
% 3D : marqueurs en ligne et temps en 3e dim.)

if nargin ==1
    options = 'normal' ;
end

donnees_trc=lire_donnees_trc(fichierTRC);

switch options
    case 'normal'
        %% Ouverture du trc et rangement dans un struct
        coord_trc=struct;
        for i_marker=1:length(donnees_trc.noms)
            nom_mrk_trc=donnees_trc.noms{i_marker};
            if ~strcmp(nom_mrk_trc(1:end-2),'C_')==1
                coord_trc.(nom_mrk_trc)=donnees_trc.coord(:,i_marker*3-2:i_marker*3)';
                coord_trc.(nom_mrk_trc)=coord_trc.(nom_mrk_trc)';
            end
        end  
    case 'matrix'
        coord_trc.noms = donnees_trc.noms;
        nMarkers = size(coord_trc.noms,1);
        nFrames = size(donnees_trc.coord,1);
        coord_trc.matrix(nMarkers,3,nFrames)=0;
        for i_marker = 1:nMarkers
            coord_trc.matrix(i_marker,:,:) = permute(donnees_trc.coord(:,i_marker*3-2:i_marker*3),[3 2 1]);
        end
       [liste_ordonnee, index] = sort(coord_trc.noms);
       coord_trc.noms = liste_ordonnee;
       coord_trc.matrix = coord_trc.matrix(index,:,:);
end