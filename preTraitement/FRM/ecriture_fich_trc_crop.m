function   [output, VICON]=ecriture_fich_trc_crop(VICON, nom_sortie, path_sortie, crop_inf, crop_sup)
% crop en frame vicon
clear coord_marqueurs
% disp('écriture du fichier trc')

%definition de la plage temporelle
Time=VICON.Time;
if isempty(crop_inf)
    crop_inf=1;
elseif isnan(crop_inf)
    crop_inf=1;
end
if isempty(crop_sup)
    crop_sup=length(Time);
elseif isnan(crop_sup)
    crop_sup=length(Time);
end

% %changement des unités %%% Fait dans lire_fichier_c3d
% if strcmp(VICON.Info.unit,'mm')==1,
%     change=1/1000;
%     VICON.Info.unit='m'; disp('changement d''unité')
% elseif strcmp(VICON.Info.unit,'m')==1,
    change=1;
% else
%     change=1; disp('unité des données Vicon sont ni mm ni m')
% end

nb_phase=length(crop_sup);
for iphase = 1:nb_phase
    
    num_frame=[crop_inf(iphase):1:crop_sup(iphase)]';%vecteur des numéros de frame
    nb_frame=length(num_frame);% nombre total de frames

    structure=VICON.Marqueurs;
    noms_marqueurs=fieldnames(structure);
    nb_marqueurs=length(noms_marqueurs);

    Time=VICON.Time(crop_inf(iphase):crop_sup(iphase));
    if size(Time,1)==1, Time=Time'; end
    
    output=NaN(nb_frame,nb_marqueurs*3+2);
    output(:,1:2)=[num_frame Time];
    dataheader1 = 'Frame#\tTime\t';
    dataheader2 = '\t\t';
    % format_text = '%i\t%i\t';
    format_text = '%i\t%2.4f\t';
    for imark=1:nb_marqueurs,
        dataheader1 = [dataheader1 noms_marqueurs{imark} '\t\t\t'];
        dataheader2 = [dataheader2 'X' num2str(imark) '\t'...
                                    'Y' num2str(imark) '\t'...
                                    'Z' num2str(imark) '\t'];
        %     format_text = [format_text '%i\t%i\t%i\t'];
        format_text = [format_text '%f\t%f\t%f\t'];
        coord_marqueurs=structure.( noms_marqueurs{imark} ) ;
        coord_marqueurs=coord_marqueurs(crop_inf(iphase):crop_sup(iphase),:)*change;
        output(:,imark*3:imark*3+2)=coord_marqueurs;
    end

    dataheader1 = [dataheader1 '\n'];
    dataheader2 = [dataheader2 '\n'];
    format_text = [format_text '\n'];

    mkdir(path_sortie);
<<<<<<< HEAD
    newfilename = strcat(path_sortie,'\',sprintf('%s_part%g',nom_sortie,iphase),'.trc');
    newfilename = fullfile(path_sortie,[nom_sortie,'.trc']);
=======
    if nb_phase==1, newfilename = strcat(path_sortie,'\',nom_sortie,'.trc');
    else            newfilename = strcat(path_sortie,'\',sprintf('%s_part%g',nom_sortie,iphase),'.trc');
    end   
>>>>>>> dev_diane_ENSAM
    fid_1 = fopen(newfilename,'w');

    % écriture de l'en-tête
    fprintf(fid_1,'%s\t%s\t%s\t%s\n', 'PathFileType','4','(X/Y/Z)',newfilename);
    fprintf(fid_1,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
    fprintf(fid_1,'%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\n', VICON.Info.frequence, VICON.Info.frequence, VICON.Info.NumFrames, nb_marqueurs, VICON.Info.unit, VICON.Info.frequence,'1',VICON.Info.NumFrames);
    fprintf(fid_1, dataheader1);
    fprintf(fid_1, dataheader2);

    % écriture des données des marqueurs
    fprintf(fid_1, format_text, output');

    % close the file
    fclose(fid_1);
end %iphase

end

