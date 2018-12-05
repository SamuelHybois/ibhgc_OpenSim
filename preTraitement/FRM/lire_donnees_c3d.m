function [st_marqueurs,st_VICON] = lire_donnees_c3d(path_cur_file)
    
    [st_VICON,~] = recuperation_c3d(path_cur_file);         % extraction donnees c3d static
    st_marqueurs = NettoieMarkerLabels2(st_VICON.Marqueurs);% enlève les marqueurs sans label
    Marqueurs = fieldnames(st_marqueurs);                   % récupère la liste des marqueurs
    st_marqueurs = zero2NaN(st_marqueurs);                  % transforme les [0 0 0] en NaN            
    [st_VICON,st_marqueurs] = changement_repere_VICON_2_OS(st_VICON,st_marqueurs,Marqueurs);
    if sum(strcmp(Marqueurs,'SCLM'))                         % recale et renomme les marqueurs du scaploc
        [~,file,~] = fileparts(path_cur_file) ;
        [sign,~,side] = side_of_acquisition(file);
        st_marqueurs = mark_scaploc2mark_scapula(st_marqueurs,side,sign); 
    end
end